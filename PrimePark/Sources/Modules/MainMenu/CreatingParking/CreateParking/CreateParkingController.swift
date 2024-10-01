protocol CreateParkingControllerProtocol: ModalRouterSourceProtocol {
    func setChoosenDate(date: String)
    func guestDidAdd(_ guest: Guest)
    func dismissController()
    func updateGuests(_ guests: [Guest])
    func changeAccess(_ role: Role)
    
    //callback
    
    func loadingDone()
}

final class CreateParkingController: UIViewController {
    private lazy var createParkingView: CreateParkingView = {
        var view = Bundle.main.loadNibNamed("CreateParkingView", owner: nil, options: nil)?.first as? CreateParkingView ?? CreateParkingView()
        return view
    }()

    private let presenter: CreateParkingPresenterProtocol
    private let isFullAccess = LocalAuthService.shared.apartment?.getRole == .brigadier ? false : true
    
    private lazy var parametersController: ParametersController = setupParamters()
    private let panelTransition = PanelTransition()
	private let parking: Parking?

    init(presenter: CreateParkingPresenterProtocol, parking: Parking? = nil) {
        self.presenter = presenter
        self.parking = parking

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.createParkingView
        self.createParkingView.addDelegate(self)
		
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

		self.createParkingView.setChoosenDate(date: dateFormatter.string(from: Date()))

		if let parking = self.parking {
			self.createParkingView.addGuest(Guest(fullName: parking.name, phone: parking.phone))
			self.createParkingView.setCarModel(parking.carModel)
			self.createParkingView.setCarNumber(parking.carNumber)
		}
		self.createParkingView.commonInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        createParkingView.setEntrance(entrance: isFullAccess ? .central : .service)
    }
}

extension CreateParkingController: CreateParkingControllerProtocol {
    func setChoosenDate(date: String) {
        self.createParkingView.setChoosenDate(date: date)
    }

    func guestDidAdd(_ guest: Guest) {
        self.createParkingView.addGuest(guest)
    }

    func dismissController() {
        self.navigationController?.popViewController(animated: true)
    }

    func updateGuests(_ guests: [Guest]) {
        self.createParkingView.addGuestsArray(guests)
    }
    
    func changeAccess(_ role: Role) {
        self.createParkingView.changeAccess(role)
    }
    
    func loadingDone() {
        createParkingView.loadingDone()
    }
}

extension CreateParkingController: CreateParkingViewProtocol {
    //swiftlint:disable all
    
    func choosePayer(isResident: Bool) {
        self.presenter.choosenPayer(isResident: isResident)
    }
    
    func chooseEntrance() {
        ModalRouter(source: self, destination: parametersController, modalPresentationStyle: .custom).route()
    }
    
    private func setupParamters() -> ParametersController {
        
        var content = [
            ParametersData(name: localizedWith("createPass.entrance.service"), isSelected: !isFullAccess)
        ]
        
        if isFullAccess {
            content.insert(ParametersData(name: localizedWith("createPass.entrance.front"), isSelected: isFullAccess), at: 0)
        }
        
        parametersController = ParametersAssembly(content: content).makeAsInheritor

        parametersController.choosenClosure = { [weak self] (content, row) in
            guard let strongSelf = self else { return }
            
            let choosenEntrance = strongSelf.isFullAccess ? Entrance(rawValue: row) ?? .service : .service
            strongSelf.createParkingView.setEntrance(entrance: choosenEntrance)
            strongSelf.presenter.choosenEntrance(entrance: choosenEntrance)
        }
        
        panelTransition.currentPresentation = .dynamic(height: parametersController.dynamicSize)
        
        parametersController.transitioningDelegate = panelTransition
        return parametersController
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }

    func info() {
        self.presenter.showInfo()
    }

    func chooseDate() {
        self.presenter.openCalendar()
    }

    func needAddGuest() {
        self.presenter.needAddGuest()
    }

    func deleteGuest(at index: Int) {
        presenter.guestDidDelete(index: index)
    }

    func createParking(type: ParkingType, carNumber: String, carModel: String?, isResidentPay: Bool) {
        self.presenter.createParking(
			type: type,
			carNumber: carNumber,
			carModel: carModel,
			isResidentPay: isResidentPay
		)
    }

    func showGuestsError() {
        presenter.showGuestsError()
    }

    func showEmptyDataError() {
        presenter.showEmptyDataError()
    }
}
