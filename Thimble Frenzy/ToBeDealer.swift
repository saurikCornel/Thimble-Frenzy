import SwiftUI
import Combine
import UIKit
class GameTimer: ObservableObject {
    @Published var remainingTime = 6
    private var timer: AnyCancellable?
    
    func start() {
        timer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.stop()
                }
            }
    }
    
    func stop() {
        timer?.cancel()
    }
}

struct ToBeDealer: View {
    @State private var currentStep = 0 // 0 - старт, 1 - правила, 2 - игра, 3 - выигрыш, 4 - проигрыш
    @State private var shuffledCups = ["cup2", "cup2", "cup2"] // Массив для хранения изображений стаканов
    @State private var cupOffsets: [CGSize] = [.zero, .zero, .zero] // Смещения для анимации перемешивания
    @State private var isShuffling = false // Флаг для отслеживания процесса перемешивания
    @State private var tapCount = 0 // Счетчик тапов
    @StateObject private var gameTimer = GameTimer() // Таймер игры
    @AppStorage("coinscore") var coinscore: Int = 10

    // Размеры стаканов
    @State private var cupWidth: CGFloat = 120
    @State private var cupHeight: CGFloat = 120
    
    let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("backgroundToBeDealer")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(isPad ? 1 : 1.1)
                
                if currentStep == 0 {
                    // Экран старта
                    ZStack {
                        // Кнопка "назад" в левом верхнем углу
                        Button(action: {
                            ApplyGuard.shared.currentScreen = .MENU // Возвращаемся к главному меню
                        }) {
                            Image("back") // Картинка кнопки "назад"
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .position(x: 20, y: 40) // Точно позиционируем кнопку в углу
                        
                        // Основное содержимое экрана старта
                        VStack {
                            Spacer() // Отступ сверху для центрирования
                            Button(action: {
                                currentStep = 1
                            }) {
                                Image("startpic") // Картинка кнопки старт
                                    .resizable()
                                    .frame(width: 500, height: 200) // Размеры кнопки
                            }
                            Spacer() // Отступ снизу для центрирования
                        }
                    }
                    
                } else if currentStep == 1 {
                    // Экран правил
                    Image("rulesImage") // Картинка с правилами
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, -30)
                        .scaleEffect(isPad ? 0.7 : 1)
                        .onTapGesture {
                            currentStep = 2 // Переход к игре
                            startGame() // Начинаем игру
                        }
                    
                } else if currentStep == 2 {
                    // Игровой экран
                    VStack {
                        VStack {
                            Spacer()
                            HStack(spacing: 50) {
                                ForEach(0..<shuffledCups.count, id: \.self) { index in
                                    Image(shuffledCups[index])
                                        .resizable()
                                        .frame(width: cupWidth, height: cupHeight) // Установка размеров стаканов
                                        .offset(cupOffsets[index])
                                }
                            }
                            .padding()
                            
                            Spacer()
                        }
                        Spacer()
                    }
                    .onTapGesture {
                        if currentStep == 2 {
                            handleTap()
                        }
                    }
                    .onChange(of: gameTimer.remainingTime) { newValue in
                        if newValue == 0 && currentStep == 2 {
                            // Завершаем игру как проигранную только если время истекло и победное условие не выполнено
                            if tapCount < 9 { // Проверяем, что игрок не выполнил условие победы
                                endGame(success: false)
                            }
                        }
                    }
                    
                } else if currentStep == 3 {
                    // Экран выигрыша
                    ZStack {
                        Image("winview") // Фоновая картинка для выигрыша
                            .resizable()
//                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                // Кнопка "Главное меню"
                                Button(action: {
                                    ApplyGuard.shared.currentScreen = .MENU
                                }) {
                                    Image("menuButton") // Картинка кнопки "Главное меню"
                                        .resizable()
                                        .frame(width: isPad ? 300 : 200, height: isPad ? 120 : 100)
                                }
                            }
                            .padding(.bottom, 30)
                        }
                    }
                    
                } else if currentStep == 4 {
                    // Экран проигрыша
                    ZStack {
                        Image("loseview") // Фоновая картинка для проигрыша
                            .resizable()
//                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Spacer()
                            
                            VStack {
                                // Кнопка "Главное меню"
                                Button(action: {
                                    ApplyGuard.shared.currentScreen = .MENU
                                }) {
                                    Image("homeButton") // Картинка кнопки "Главное меню"
                                        .resizable()
                                        .frame(width: isPad ? 300 : 200, height: isPad ? 120 : 100)
                                }
                                
                                // Кнопка "Сыграть снова"
                                Button(action: {
                                    currentStep = 2
                                    startGame() // Начинаем новую игру
                                }) {
                                    Image("tryagainButton") // Картинка кнопки "Сыграть снова"
                                        .resizable()
                                        .frame(width: isPad ? 300 : 200, height: isPad ? 120 : 100)
                                }
                            }
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func startGame() {
        isShuffling = false
        tapCount = 0
        gameTimer.remainingTime = 6
        gameTimer.start()
    }
    
    private func endGame(success: Bool) {
        gameTimer.stop()
        if success {
            currentStep = 3 // Переход к экрану выигрыша
            
            // Добавляем 20 монет при выигрыше
            coinscore += 20
        } else {
            currentStep = 4 // Переход к экрану проигрыша
        }
    }
    
    private func shuffleCups() {
        isShuffling = true
        
        let totalShuffles = 1
        var delay: TimeInterval = 0.2
        
        for _ in 0..<totalShuffles {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let firstIndex = Int.random(in: 0..<self.shuffledCups.count)
                var secondIndex = Int.random(in: 0..<self.shuffledCups.count)
                
                while firstIndex == secondIndex {
                    secondIndex = Int.random(in: 0..<self.shuffledCups.count)
                }
                
                // Вычисляем новые смещения стаканов
                let offsetX = (firstIndex < secondIndex ? 1 : -1) * 100
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.cupOffsets[firstIndex].width += CGFloat(offsetX)
                    self.cupOffsets[secondIndex].width -= CGFloat(offsetX)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.cupOffsets[firstIndex] = .zero
                        self.cupOffsets[secondIndex] = .zero
                    }
                    
                    // Меняем местами стаканы в массиве
                    self.shuffledCups.swapAt(firstIndex, secondIndex)
                }
            }
            delay += 0.4
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalShuffles) * 0.4) {
            isShuffling = false
        }
    }
    
    private func handleTap() {
        if !isShuffling {
            tapCount += 1
            shuffleCups()
            
            if tapCount >= 9 { // Условие для победы
                endGame(success: true)
            }
        }
    }
}

#Preview {
    ToBeDealer()
}
