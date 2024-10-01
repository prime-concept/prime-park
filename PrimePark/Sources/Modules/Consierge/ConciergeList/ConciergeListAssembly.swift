import UIKit

final class ConciergeListAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = ConciergeListPresenter(
            endpoint: IssuesEndpoint(),
            authService: self.localAuth
        )
        let controller = ConciergeListController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
