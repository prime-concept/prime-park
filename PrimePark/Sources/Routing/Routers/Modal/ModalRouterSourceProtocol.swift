import Foundation
import UIKit

protocol ModalRouterSourceProtocol: AnyObject {
    func present(module: UIViewController)
    func dismiss(withCompletion: @escaping () -> Void)
}

extension UIViewController: ModalRouterSourceProtocol {
    @objc
    func present(module: UIViewController) {
        self.present(module, animated: true)
    }
    @objc
    func dismiss(withCompletion: @escaping () -> Void) {
        self.dismiss(animated: true) {
            withCompletion()
        }
    }
}
