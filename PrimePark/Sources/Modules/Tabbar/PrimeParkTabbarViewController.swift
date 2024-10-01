import UIKit
import ChatSDK
import CoreMedia

final class PrimeParkTabbarViewController: UITabBarController {
    private weak var chatController: UIViewController?

    private var currentRole = LocalAuthService.shared.apartment?.getRole ?? .resident {
        didSet {
            updateTabsEnabling(self.tabBar.items)
            //if currentRole == .brigadier || currentRole == .guest {
                if let first = viewControllers?.first as? PrimeParkNavigationController {
                    first.popToRootViewController(animated: true)
                }
            //}
        }
    }
    private var availableTabs: [AvailableTabs] = []

    override func viewDidLoad() {
        super.viewDidLoad()
		
        addListener()
		
		tabBar.backgroundColor = Palette.darkColor
		
        self.availableTabs = [.home, .concierge/*.concierge(self)*/, .guide, .prime, .profile]

        self.updateTabControllers()

        self.updateTabBarStyle()

        self.selectedIndex = self.availableTabs.firstIndex(of: .home) ?? 0
    }
    
    private func updateTabControllers() {
        self.setViewControllers(getPresentedModules(), animated: false)
    }

    private func getPresentedModules() -> [UIViewController] {
        var result: [UIViewController] = []
        var tabBarItems: [UITabBarItem] = []
        for tab in self.availableTabs {
            let module = tab.module
            var navigation: PrimeParkNavigationController
            switch tab {
            case .prime:
                navigation = PrimeParkNavigationController(rootViewController: module)
            default:
                navigation = PrimeParkNavigationController(rootViewController: module, isStatusBarEnabled: true)
            }
            navigation.navigationBar.applyStyle()
            navigation.tabBarItem = tab.tabBarItem
            module.navigationItem.title = tab.tabBarItem.title
            result += [navigation]
            tabBarItems.append(navigation.tabBarItem)
            if case .concierge = tab {
                self.chatController = module
            }
        }
        updateTabsEnabling(tabBarItems)

        return result
    }
    
    private func updateTabsEnabling(_ items: [UITabBarItem]?) {
        guard let arr = items else { return }
        switch currentRole {
        case .resident:
            arr[2].isEnabled = true
            arr[3].isEnabled = true
        case .cohabitant:
            arr[2].isEnabled = true
            arr[3].isEnabled = true
        case .brigadier:
            arr[2].isEnabled = false
            arr[3].isEnabled = false
        case .guest:
            arr[2].isEnabled = false
            arr[3].isEnabled = false
        }
    }

    private func updateTabBarStyle() {
        tabBar.tintColor = Palette.goldColor
        tabBar.isTranslucent = false
        tabBar.barTintColor = UIColor(hex: 0x363636).withAlphaComponent(0.9)
    }
}

extension PrimeParkTabbarViewController: ChannelModuleOutputProtocol {
    func didTextViewEditingStatusUpdate(with value: Bool) {
    }
    func didMessageSendingStatusUpdate(with status: ChannelMessageSendingStatus, uid: String) {
    }
    func didChannelControllerStatusUpdate(with status: ChannelControllerStatus) {
    }
    func didChannelAttachementsUpdate(_ update: ChannelAttachmentsUpdate, totalCount: Int) {
    }
    func didChannelVoiceMessageStatusUpdate(with status: ChannelVoiceMessageStatus) {
    }
    func requestPhoneCall(number: String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    func requestPresentation(for controller: UIViewController, completion: (() -> Void)?) {
        controller.modalPresentationStyle = .overFullScreen
        self.chatController?.present(controller, animated: true, completion: completion)
    }

    var shouldShowSafeAreaView: Bool { false }
}

extension PrimeParkTabbarViewController {
    @objc
    func hasChangedRoom(notification: Notification) {
        guard let rooms = LocalAuthService.shared.user?.parcingRooms else { return }
        guard let index = notification.userInfo?["roomNumber"] as? Int else { return }
        currentRole = Role(rawValue: rooms[index].role) ?? .resident
    }
    
    func addListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(hasChangedRoom(notification:)), name: .roomChanged, object: nil)
    }
}
