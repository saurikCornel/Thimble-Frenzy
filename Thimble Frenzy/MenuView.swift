import SwiftUI

struct MenuView: View {
    

    var body: some View {
        GeometryReader { geometry in
            var isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if isLandscape {
                        VStack {
                            
                            HStack(spacing: 90)  {
                                ButtonTemplateSmall(image: "rulesBtn", action: {ApplyGuard.shared.currentScreen = .ABOUT})
                                Spacer()
                                BalanceTemplate()
                                Spacer()
                                ButtonTemplateSmall(image: "settingsBtn", action: {ApplyGuard.shared.currentScreen = .SETTINGS})
                            }
                            
                            Spacer()
                            
                            
                            ButtonTemplateBig(image: "playBtn", action: {ApplyGuard.shared.currentScreen = .MAINGAME})
                            
                            Spacer()
                            
                            
                            HStack  {
                                ButtonTemplateSmall(image: "dailyBtn", action: {ApplyGuard.shared.currentScreen = .DAILY})
                                Spacer()
                                ButtonTemplateSmall(image: "shopBtn", action: {ApplyGuard.shared.currentScreen = .SHOP})
                                Spacer()
                                ButtonTemplateSmall(image: "dillerBtn", action: {ApplyGuard.shared.currentScreen = .TOBEDEALER})
                            }
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
                Image(.backgroundMenu)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
//            .overlay(
//                ZStack {
//                    if isLandscape {
//                        HStack {
//                            BalanceTemplate()
//                        }
//                        .position(x: geometry.size.width / 1.2, y: geometry.size.height / 9)
//                    } else {
//                        BalanceTemplate()
//                            .position(x: geometry.size.width / 1.3, y: geometry.size.height / 9)
//                    }
//                }
//            )

        }
    }
}




struct BalanceTemplate: View {
    @AppStorage("coinscore") var coinscore: Int = 10
    var body: some View {
        ZStack {
            Image("balancePlate")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 70)
                .overlay(
                    ZStack {
                            Text("\(coinscore)")
                            .foregroundColor(.white)
                            .fontWeight(.heavy)
                            .font(.title3)
                            .position(x: 60, y: 32)
                        
                    }
                )
        }
    }
}


struct ButtonTemplateSmall: View {
    var image: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 90)
                .cornerRadius(10)
                .shadow(radius: 10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }
    }
}

struct ButtonTemplateBig: View {
    var image: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 100)
                .cornerRadius(10)
                .shadow(radius: 10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }
    }
}



#Preview {
    MenuView()
}

