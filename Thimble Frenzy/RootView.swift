import Foundation
import SwiftUI


struct RootView: View {
    @ObservedObject var nav: ApplyGuard = ApplyGuard.shared
    var body: some View {
        switch nav.currentScreen {
                                        
        case .MENU:
            MenuView()
        case .LOADING:
            LoadingScreen()
        case .MAINGAME:
            MainGame()
        case .SETTINGS:
            SettingsView()
        case .DAILY:
            DailyBonus()
        case .SHOP:
            ShopView()
        case .ABOUT:
            AboutScreen()
        case .TOBEDEALER:
            ToBeDealer()
            
        }

    }
}
