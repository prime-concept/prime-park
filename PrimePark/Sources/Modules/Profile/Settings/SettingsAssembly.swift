import UIKit

final class SettingsAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = SettingsPresenter(authService: self.localAuth, user: localAuth.user)
        let controller = SettingsController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
