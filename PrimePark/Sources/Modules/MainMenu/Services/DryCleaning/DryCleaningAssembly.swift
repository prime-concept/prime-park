import UIKit

final class DryCleaningAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = DryCleaningPresenter(
            endpoint: IssuesEndpoint(),
            authService: self.localAuth
        )
        let controller = DryCleaningViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
