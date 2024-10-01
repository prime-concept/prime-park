final class ParkingListAssembly: Assembly {
    private let localAuth: LocalAuthService

    init(authService: LocalAuthService) {
        self.localAuth = authService
    }

    func make() -> UIViewController {
        let presenter = ParkingListPresenter(
            endpoint: ParkingEndpoint(),
            authService: self.localAuth
        )
        let controller = ParkingListController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
