import UIKit

final class ProfileAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = ProfilePresenter(authService: self.localAuth, endpoint: SettingsEndpoint())
        let controller = ProfileController(presenter: presenter, user: localAuth.user, room: localAuth.apartment)
        presenter.controller = controller
        return controller
    }
}
