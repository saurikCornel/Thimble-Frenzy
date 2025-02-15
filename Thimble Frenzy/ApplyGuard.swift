import Foundation


enum AvailableScreens {
    case MENU
    case LOADING
    case MAINGAME
    case SETTINGS
    case DAILY
    case SHOP
    case ABOUT
    case TOBEDEALER
}

class ApplyGuard: ObservableObject {
    @Published var currentScreen: AvailableScreens = .LOADING
    static var shared: ApplyGuard = .init()
}
