final class ResidentListAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = ResidentListPresenter(endpoint: SettingsEndpoint(), authService: self.localAuth)
        let controller = ResidentListController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
