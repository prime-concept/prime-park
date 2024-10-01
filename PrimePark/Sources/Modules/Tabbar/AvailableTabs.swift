import UIKit
import ChatSDK

enum AvailableTabs: Equatable {
    static func == (lhs: AvailableTabs, rhs: AvailableTabs) -> Bool {
        false
    }

    case home, concierge/*concierge(ChannelModuleOutputProtocol)*/, guide, prime, profile

    var tabBarItem: UITabBarItem {
        switch self {
        case .home:
            let barItem = LocalizableTabBarItem(
                title: "tabbar.home".localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru"),
                image: UIImage(named: "home-icon"),
                selectedImage: nil
            )
            barItem.localizedKey = "tabbar.home"
            return barItem
        case .concierge:
            let barItem = LocalizableTabBarItem(
                title: "tabbar.concierge".localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru"),
                image: UIImage(named: "concierge-icon"),
                selectedImage: nil
            )
            barItem.localizedKey = "tabbar.concierge"
            return barItem
        case .guide:
            let barItem = LocalizableTabBarItem(
                title: "tabbar.cityguide".localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru"),
                image: UIImage(named: "cityguide-icon"),
                selectedImage: nil
            )
            barItem.localizedKey = "tabbar.cityguide"
            return barItem
        case .prime:
            let barItem = LocalizableTabBarItem(
                title: "tabbar.prime".localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru"),
                image: UIImage(named: "prime-icon"),
                selectedImage: nil
            )
            barItem.localizedKey = "tabbar.prime"
            return barItem
        case .profile:
            let barItem = LocalizableTabBarItem(
                title: "tabbar.profile".localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru"),
                image: UIImage(named: "profile-icon"),
                selectedImage: nil
            )
            barItem.localizedKey = "tabbar.profile"
            return barItem
        }
    }

    var module: UIViewController {
        switch self {
        case .home:
            return HomeViewController()
        /*case .concierge(let viewController):
            let authService = LocalAuthService.shared
            guard let username = authService.user?.username, !username.isEmpty,
                let token = authService.token?.accessToken, !token.isEmpty
            else {
                fatalError("User doesn`t exist")
            }

            return ChatAssembly(
                chatToken: token,
                channelID: "N\(username)",
                channelName: "Чат",
                clientID: "C\(username)",
                sourceViewController: viewController
            ).make()*/
        case .concierge:
            return ConciergeListAssembly(authService: LocalAuthService.shared).make()
        case .profile:
            return ProfileAssembly(authService: LocalAuthService.shared).make()
        case .guide:
            guard let token = LocalAuthService.shared.token?.accessToken else {
                return PrimeInfoController()
            }
            return GuideController(token: token)
        default:
            return PrimeInfoController()//SplashViewController()
        }
    }
}
