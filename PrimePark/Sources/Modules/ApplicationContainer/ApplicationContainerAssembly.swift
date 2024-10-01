import UIKit

final class ApplicationContainerAssembly: Assembly {
    func make() -> UIViewController {
        let presenter = ApplicationContainerPresenter(authService: .shared, endpoint: AuthEndpoint())
        let controller = ApplicationContainerViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
