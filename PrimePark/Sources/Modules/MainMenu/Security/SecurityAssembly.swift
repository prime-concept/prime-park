import UIKit

final class SecurityAssembly: Assembly {

    func make() -> UIViewController {
        let presenter = SecurityPresenter(
            endpoint: SecurityEndpoint()
        )
        let controller = SecurityViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
