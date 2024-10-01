import UIKit

final class PassListAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = PassListPresenter(
            endpoint: PassEndpoint(),
            authService: self.localAuth
        )
        let controller = PassListController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
