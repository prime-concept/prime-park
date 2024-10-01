import UIKit

final class CarWashAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = CarWashPresenter(
            endpoint: CarWashEndpoint(),
            authService: self.localAuth
        )
        let controller = CarWashViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
