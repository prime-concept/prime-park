import Foundation

protocol RouterProtocol: AnyObject {
	func route()
}

protocol MainScreenRouterProtocol: AnyObject {
	func routeToMain()
}

extension MainScreenRouterProtocol {
	func routeToMain() {
		guard
			let window = UIApplication.shared.windows.first,
			let rootViewController = window.rootViewController as? ApplicationContainerViewController else { return }
		rootViewController.displayModule(assembly: AuthAssembly())
	}
}
