import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = CheckingSound()
    
    var body: some View {
        GeometryReader { geometry in
            var isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                if isLandscape {
                    ZStack {
                        
                        VStack {
                            HStack {
                                Image("back")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        ApplyGuard.shared.currentScreen = .MENU
                                    }
                                Spacer()
                            }
                            Spacer()
                        }
                        
                        
                        Image(.settingPlate)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 350)
                            .overlay(
                                ZStack {
                                    Image(.settingsText)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 80)
                                        .position(x: 170, y: 40)
                                }
                            )
                        
                        
                        
                        
                        VStack {
                            HStack(spacing: 30) {
                                Image(.muscPic)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                
                                if settings.musicEnabled {
                                    Image(.soundOn)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 70)
                                        .onTapGesture {
                                            settings.musicEnabled.toggle()
                                        }
                                } else {
                                    Image(.soundOff)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 70)
                                        .onTapGesture {
                                            settings.musicEnabled.toggle()
                                        }
                                }
                            }
                            
                            HStack(spacing: 30) {
                                Image(.vibroPic)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                
                                
                                if settings.vibroEnabled {
                                    Image(.soundOn)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 70)
                                        .onTapGesture {
                                            settings.vibroEnabled.toggle()
                                        }
                                } else {
                                    Image(.soundOff)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 70)
                                        .onTapGesture {
                                            settings.vibroEnabled.toggle()
                                        }
                                }
                            }
                            
                        }
//                        .padding(.top, 50)
                        
                        
                        VStack {
                            Spacer()
                            HStack {
                                Image(.rateUsBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 90)
                                    .onTapGesture {
                                        openURLInSafari(urlString: openAppURL)
                                    }
                            
                            }
                        }
                    }
                } else {
                    ZStack {
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image(.backgroundSettings)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
        }
    }
}

extension SettingsView {
    func openURLInSafari(urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Не удалось открыть URL: \(urlString)")
            }
        } else {
            print("Неверный формат URL: \(urlString)")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SoundManager.shared)
}
