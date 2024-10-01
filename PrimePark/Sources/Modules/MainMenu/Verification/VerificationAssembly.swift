import UIKit

final class VerificationAssembly: Assembly {
    private let phone: String

    init(phone: String) {
        self.phone = phone
    }

    func make() -> UIViewController {
        let presenter = VerificationPresenter(
            endpoint: AuthEndpoint(),
            phone: self.phone,
            authService: .shared
        )
        let controller = VerificationViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
