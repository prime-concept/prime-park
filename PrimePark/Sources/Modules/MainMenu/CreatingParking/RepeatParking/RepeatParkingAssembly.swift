final class RepeatParkingAssembly: Assembly {
    private weak var parkingList: ParkingListPresenterProtocol?
    private let localAuth: LocalAuthService
    private let parking: Parking
    private let passId: Int

    init(
		source: ParkingListPresenterProtocol?,
		authService: LocalAuthService,
		parking: Parking,
		passID: Int
	) {
        self.parkingList = source
        self.localAuth = authService
        self.parking = parking
        self.passId = passID
    }
	
    func make() -> UIViewController {
        let presenter = RepeatParkingPresenter(
            source: parkingList,
            endpoint: ParkingEndpoint(),
            authService: localAuth,
			parking: parking,
            passId: passId
        )
		let controller = RepeatParkingController(presenter: presenter, parking: parking)
        presenter.controller = controller
        return controller
    }
}
