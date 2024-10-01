final class CreateParkingAssembly: Assembly {
    private let localAuth: LocalAuthService
    private let recentGuests: [Guest]
    private let parking: Parking?

    init(authService: LocalAuthService, recentGuests: [Guest], parking: Parking? = nil) {
        self.localAuth = authService
        self.recentGuests = recentGuests
		self.parking = parking
    }

    func make() -> UIViewController {
        let presenter = CreateParkingPresenter(
            endpoint: ParkingEndpoint(),
            authService: self.localAuth,
            recentGuests: self.recentGuests,
            parking: parking
        )
		let controller = CreateParkingController(presenter: presenter, parking: self.parking)
        presenter.controller = controller
        return controller
    }
}
