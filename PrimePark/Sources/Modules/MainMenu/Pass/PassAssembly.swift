final class PassAssembly: Assembly {
    private weak var passList: PassListPresenterProtocol?
    private let localAuth: LocalAuthService
    private let pass: IssuePass
    private let passId: Int

    init(source: PassListPresenterProtocol?, authService: LocalAuthService, pass: IssuePass, passID: Int) {
        self.passList = source
        self.localAuth = authService
        self.pass = pass
        self.passId = passID
    }

    func make() -> UIViewController {
        let presenter = PassPresenter(
            source: passList,
            endpoint: PassEndpoint(),
            authService: localAuth,
            pass: pass,
            passId: passId
        )
        let controller = PassController(presenter: presenter, pass: pass)
        presenter.controller = controller
        return controller
    }
}
