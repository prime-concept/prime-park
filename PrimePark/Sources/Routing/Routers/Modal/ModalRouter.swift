import Foundation
import UIKit

class ModalRouter: SourcelessRouter, RouterProtocol, MainScreenRouterProtocol {
    private var destination: UIViewController
    private var source: ModalRouterSourceProtocol?

    init(
        source optionalSource: ModalRouterSourceProtocol?,
        destination: UIViewController,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        modalTransitionStyle: UIModalTransitionStyle = .coverVertical
    ) {
        self.destination = destination
        self.destination.modalPresentationStyle = modalPresentationStyle
        self.destination.modalTransitionStyle = modalTransitionStyle
        super.init()
        let possibleSource = self.currentNavigation?.topViewController
        if let source = optionalSource ?? possibleSource {
            print(source)
            self.source = source
        } else {
            self.source = self.window?.rootViewController
        }
    }

    func route() {
        self.source?.present(module: self.destination)
    }
	
    func routeToMain() {
        self.source?.present(module: currentTabBarController ?? UIViewController())
    }
}
