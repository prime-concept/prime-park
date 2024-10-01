import UIKit

final class AuthAssembly: Assembly {
    func make() -> UIViewController {
        let presenter = AuthPresenter(endpoint: AuthEndpoint())
        let controller = AuthViewController(presenter: presenter)
        presenter.controller = controller
		return PrimeParkNavigationController(
			rootViewController: controller,
			isStatusBarEnabled: true,
			statusBarColor: Palette.authColor
		)
    }
}
