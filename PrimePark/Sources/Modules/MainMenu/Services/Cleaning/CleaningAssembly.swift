import UIKit

final class CleaningAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = CleaningPresenter(
            endpoint: IssuesEndpoint(),
            authService: self.localAuth
        )
        let controller = CleaningViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
