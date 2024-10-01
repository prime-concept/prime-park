import UIKit

class MainWindow: UIWindow {
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			self.presentDebugMenuIfNeeded()
		}
	}

	private func presentDebugMenuIfNeeded() {
		guard Config.isDebugEnabled else {
			return
		}

		guard let topVC = self.rootViewController?.topmostPresentedOrSelf else {
			return
		}

		if topVC is DebugMenuViewController {
			return
		}

		let debugMenu = DebugMenuViewController()
		topVC.present(debugMenu, animated: true, completion: nil)
	}
}

extension UIViewController {
	var topmostPresentedOrSelf: UIViewController {
		var result = self
		while let presented = result.presentedViewController {
			result = presented
		}
		return result
	}

	func present(animated: Bool = true, completion: (() -> Void)? = nil) {
		UIApplication.shared.keyWindow?
			.rootViewController?
			.topmostPresentedOrSelf
			.present(self, animated: animated)
	}
}
