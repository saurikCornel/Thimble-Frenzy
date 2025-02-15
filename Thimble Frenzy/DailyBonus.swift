import SwiftUI

struct DailyBonus: View {
    @State private var selectedCupIndex: Int? = nil
    @State private var showWinPlate: Bool = false
    @State private var showAlert: Bool = false
    @State private var timeRemaining: String = ""
    
    @AppStorage("lastOpenedDate") private var lastOpenedDateTimestamp: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                // Основной контент
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
                        
                        HStack {
                            ForEach(0..<3, id: \.self) { index in
                                CupView(index: index, selectedCupIndex: $selectedCupIndex, showWinPlate: $showWinPlate, lastOpenedDate: $lastOpenedDateTimestamp, showAlert: $showAlert, timeRemaining: $timeRemaining)
                            }
                        }
                        .padding(.top, 50)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    
                } else {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        RotateDeviceScreen()
                    }
                }

                // Окно rewardWindow
                if showWinPlate {
                    WinPlateView(showWinPlate: $showWinPlate, selectedCupIndex: $selectedCupIndex)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image(.backgroundDaily)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Please, wait"),
                    message: Text("You will be able to open the next cup in \(timeRemaining)."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct CupView: View {
    let index: Int
    @Binding var selectedCupIndex: Int?
    @Binding var showWinPlate: Bool
    @Binding var lastOpenedDate: Double
    @Binding var showAlert: Bool
    @Binding var timeRemaining: String

    var body: some View {
        Button(action: {
            handleCupTap()
        }) {
            Image(selectedCupIndex == index ? .winCup : .dailyCup)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
        }
    }

    private func handleCupTap() {
        let currentDate = Date()
        guard lastOpenedDate > 0 else {
            selectedCupIndex = index
            showWinPlate = true
            lastOpenedDate = currentDate.timeIntervalSince1970
            return
        }

        let lastDate = Date(timeIntervalSince1970: lastOpenedDate)
        let calendar = Calendar.current
        if let nextDate = calendar.date(byAdding: .day, value: 1, to: lastDate), currentDate < nextDate {
            let components = calendar.dateComponents([.hour, .minute, .second], from: currentDate, to: nextDate)
            timeRemaining = String(format: "%02d:%02d:%02d", components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
            showAlert = true
        } else {
            selectedCupIndex = index
            showWinPlate = true
            lastOpenedDate = currentDate.timeIntervalSince1970
        }
    }
}

struct WinPlateView: View {
    @Binding var showWinPlate: Bool
    @Binding var selectedCupIndex: Int?
    @AppStorage("coinscore") var coinscore: Int = 10

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(.rewardWindow)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .onTapGesture {
                        showWinPlate = false
                        selectedCupIndex = nil
                        coinscore += 50
                    }
            }
        }
    }
}

#Preview {
    DailyBonus()
}
