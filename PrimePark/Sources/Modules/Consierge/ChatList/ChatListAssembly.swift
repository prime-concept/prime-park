import UIKit

final class ChatListAssembly: Assembly {
    func make() -> UIViewController {
        let controller = UINavigationController(rootViewController: ChatListViewController())
        controller.navigationBar.applyStyle()
        return controller
    }
}
