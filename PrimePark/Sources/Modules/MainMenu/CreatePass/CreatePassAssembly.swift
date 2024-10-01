final class CreatePassAssembly: Assembly {
    private let localAuth: LocalAuthService
    private let pass: IssuePass?
    private let recenetGuests: [Guest]

    init(authService: LocalAuthService, pass: IssuePass?, recentGuests: [Guest]) {
        self.localAuth = authService
        self.pass = pass
        self.recenetGuests = recentGuests
    }

    func make() -> UIViewController {
        let presenter = CreatePassPresenter(
            endpoint: PassEndpoint(),
            authService: self.localAuth,
            pass: pass,
            recentGuests: self.recenetGuests
        )
        let controller = CreatePassController(presenter: presenter, pass: pass)
        presenter.controller = controller
        return controller
    }
}
