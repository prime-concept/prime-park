import UIKit

final class PassForMeListAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = PassForMeListPresenter(
            endpoint: PassEndpoint(),
            authService: self.localAuth
        )
        let controller = PassForMeListController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
