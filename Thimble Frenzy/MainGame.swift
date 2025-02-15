import SwiftUI

struct MainGame: View {
    @AppStorage("coinscore") var coinscore: Int = 10
    @State private var selectedBet: Int? = nil
    @State private var isGameStarted: Bool = false
    @State private var cups: [Int] = [0, 1, 2]
    @State private var shuffledCups: [Int] = [0, 1, 2]
    @State private var showResult: Bool = false
    @State private var result: Bool = false
    @State private var selectedCup: Int? = nil
    @State private var cupOffsets: [CGSize] = Array(repeating: .zero, count: 3)
    @State private var cupScales: [CGFloat] = Array(repeating: 1.0, count: 3)
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if isLandscape {
                    ZStack {
                        VStack {
                            HStack {
                                Image("back")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .onTapGesture {
                                        ApplyGuard.shared.currentScreen = .MENU
                                    }
                                Spacer()
                                BalanceTemplate()
                            }
                            Spacer()
                        }
                        
                        HStack(spacing: 670) {
                            VStack {
                                BetButton(imageName: "slot10", bet: 10, selectedBet: $selectedBet)
                                BetButton(imageName: "slot20", bet: 20, selectedBet: $selectedBet)
                                BetButton(imageName: "slot50", bet: 50, selectedBet: $selectedBet)
                            }
                            Spacer()
                        }
                        .padding(.top, 60)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    if selectedBet != nil {
                                        startGame()
                                    }
                                }) {
                                    Image("startBtn")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 190, height: 100)
                                }
                                .disabled(selectedBet == nil)
                            }
                        }
                        
                        HStack {
                            ForEach(0..<3, id: \.self) { index in
                                CupViewNew(index: index, shuffledCups: $shuffledCups, selectedCup: $selectedCup, showResult: $showResult, result: $result, isGameStarted: $isGameStarted, cupOffset: $cupOffsets[index], cupScale: $cupScales[index])
                                    .frame(width: geometry.size.width / 6, height: geometry.size.height / 3)
                                    .offset(cupOffsets[index])
                                    .scaleEffect(cupScales[index])
                                    .onTapGesture {
                                        if isGameStarted && selectedCup == nil {
                                            selectedCup = index
                                            checkResult()
                                        }
                                    }
                            }
                        }
                        .padding(.top, 70)
                    }
                } else {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        RotateDeviceScreen()
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image("backgroundMainGame")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
        }
    }
    
    private func startGame() {
        isGameStarted = true
        showResult = false
        selectedCup = nil
        shuffledCups = cups.shuffled() // Перемешиваем массив
        // Сброс смещений и масштабов стаканов
        for i in 0..<cupOffsets.count {
            cupOffsets[i] = .zero
            cupScales[i] = 1.0
        }
        shuffleCups()
    }
    
    private func shuffleCups() {
        let totalShuffles = 5
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
    }
    
    private func checkResult() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let selectedCup = selectedCup {
                result = shuffledCups[selectedCup] == 0 // Проверяем, содержит ли выбранный стакан алмаз
                showResult = true
                updateScore()

                // Анимация поднятия стакана
                withAnimation(Animation.easeInOut(duration: 0.5)) {
                    cupOffsets[selectedCup] = CGSize(width: 0, height: -100) // Поднимаем стакан вверх
                    cupScales[selectedCup] = 1.2 // Масштабируем стакан
                }

                // Возвращаем стакан на место после показа результата
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Задержка перед возвратом
                    withAnimation(Animation.easeInOut(duration: 0.5)) {
                        cupOffsets[selectedCup] = .zero
                        cupScales[selectedCup] = 1.0
                    }
                }
            }
        }
    }
    
    private func updateScore() {
        if result {
            coinscore += selectedBet ?? 0
        } else {
            coinscore -= selectedBet ?? 0
        }
        selectedBet = nil
        isGameStarted = false
    }
}

struct BetButton: View {
    let imageName: String
    let bet: Int
    @Binding var selectedBet: Int?
    
    var body: some View {
        Button(action: {
            selectedBet = bet
        }) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 100)
                .opacity(selectedBet == bet ? 0.5 : 1.0)
        }
    }
}

struct CupViewNew: View {
    let index: Int
    @Binding var shuffledCups: [Int]
    @Binding var selectedCup: Int?
    @Binding var showResult: Bool
    @Binding var result: Bool
    @Binding var isGameStarted: Bool
    @Binding var cupOffset: CGSize
    @Binding var cupScale: CGFloat
    @AppStorage("currentSelectedCloseCard") private var currentSelectedCloseCard: String = "cardclose1"

    var body: some View {
        ZStack {
            // Алмаз — остается на месте, скрыт за стаканом
            Image("diamond")
                .resizable()
                .scaledToFit()
                .frame(height: 40) // Размер алмаза
                .offset(y: (showResult && shuffledCups[index] == 0) ? 100 : 0) // Смещаем алмаз вниз
                .opacity((showResult && shuffledCups[index] == 0) ? 1 : 0) // Показываем алмаз только после поднятия стакана
                .animation(.easeInOut(duration: 0.5), value: showResult)

            // Стакан — поднимается, открывая алмаз
            Image(currentSelectedCloseCard)
                .resizable()
                .scaledToFit()
                .offset(cupOffset)
                .scaleEffect(cupScale)
                .animation(.easeInOut(duration: 0.5), value: cupOffset)
        }
    }
}

#Preview {
    MainGame()
}
