protocol RepeatParkingPresenterProtocol {
	func repeatParking()
}

final class RepeatParkingPresenter: RepeatParkingPresenterProtocol {
	weak var controller: RepeatParkingControllerProtocol?
	private weak var parkingList: ParkingListPresenterProtocol?

    private let endpoint: ParkingEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()
    private let passId: Int

    private var choosenDate = Date()
    private var startDate = Date()
    private var endDate = Date()
    private var entranceInt = 0
    private var entranceString = Localization.localize("Pass.entrance.front")
    private var guests: [Guest] = []
	private let parking: Parking

    init(
		source: ParkingListPresenterProtocol?,
		endpoint: ParkingEndpoint,
		authService: LocalAuthService,
		parking: Parking,
		passId: Int
	) {
        self.parkingList = source
        self.endpoint = endpoint
        self.authService = authService
        self.parking = parking
        self.passId = passId
    }

	func repeatParking() {
		self.parkingList?.repeatParking(self.parking)
	}

    // MARK: - Private API

    func showSuccessRepeat() {
        let assembly = InfoAssembly(
			title: Localization.localize("createParking.createOrder.success.title"),
			subtitle: nil,
			delegate: self
		)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    func showErrorRepeat() {
        let assembly = InfoAssembly(title: Localization.localize("createParking.createOrder.error.title"), subtitle: Localization.localize("createParking.createOrder.error.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
}

extension RepeatParkingPresenter: InfoControllerProtocol {
    func controllerDidClose() {
        self.controller?.closeController()
    }
}
