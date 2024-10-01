final class AddResidentAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = AddResidentPresenter(endpoint: PassEndpoint(), authService: self.localAuth)
        let controller = AddResidentController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
