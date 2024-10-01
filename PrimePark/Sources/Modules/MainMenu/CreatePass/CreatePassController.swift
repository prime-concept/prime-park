protocol CreatePassControllerProtocol: class, ModalRouterSourceProtocol {
    func setChoosenDate(date: String)
    func setChoosenInterval(interval: String)
    func guestDidAdd(_ guest: Guest)
    func dismissController()
    func updateGuests(_ guests: [Guest])
    func changeAccess(_ role: Role)
    
    //callback
    
    func loadingDone()
}

final class CreatePassController: UIViewController {
    private lazy var createPassView: CreatePassView = {
        var view = Bundle.main.loadNibNamed("CreatePassView", owner: nil, options: nil)?.first as? CreatePassView ?? CreatePassView()
        return view
    }()
    
    private lazy var parametersController: ParametersController = setupParamters()
    private let panelTransition = PanelTransition()

    private let presenter: CreatePassPresenterProtocol
    private let pass: IssuePass?
    private let isFullAccess = LocalAuthService.shared.apartment?.getRole == .brigadier ? false : true

    init(presenter: CreatePassPresenterProtocol, pass: IssuePass?) {
        self.presenter = presenter
        self.pass = pass
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.createPassView
        self.createPassView.addDelegate(self)
        
        self.createPassView.setChoosenDate(date: Date().dateWithCurrentTimeZone().toStr)
        createPassView.commonInit()
        let permissions = presenter.getPermissions()
        self.createPassView.addPermissions(permissions)
        guard let pass = pass else { return }
        self.createPassView.setEntrance(entrance: Entrance.entranceBy(pass.isService))
        self.createPassView.selectButton(at: pass.type)
        self.createPassView.addGuest(Guest(name: pass.firstName, surname: pass.lastName, patronymic: pass.middleName, phone: pass.phone))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        createPassView.setEntrance(entrance: isFullAccess ? .central : .service)
    }
}

extension CreatePassController: CreatePassControllerProtocol {
    
    func loadingDone() {
        createPassView.loadingDone()
    }
    
    func setChoosenDate(date: String) {
        self.createPassView.setChoosenDate(date: date)
    }

    func setChoosenInterval(interval: String) {
        self.createPassView.setChoosenDate(date: interval)
    }

    func guestDidAdd(_ guest: Guest) {
        self.createPassView.addGuest(guest)
    }

    func dismissController() {
        self.navigationController?.popViewController(animated: true)
    }

    func updateGuests(_ guests: [Guest]) {
        self.createPassView.addGuestsArray(guests)
    }
    
    func changeAccess(_ role: Role) {
        self.createPassView.changeAccess(role)
    }
}

extension CreatePassController: CreatePassViewDeleagate {
    func back() {
        navigationController?.popViewController(animated: true)
    }

    func info() {
        self.presenter.showInfo()
    }

    func chooseDate(interval: Bool) {
        self.presenter.openCalendar(interval: interval)
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
            strongSelf.createPassView.setEntrance(entrance: choosenEntrance)
            strongSelf.presenter.choosenEntrance(entrance: choosenEntrance)
        }
        
        panelTransition.currentPresentation = .dynamic(height: parametersController.dynamicSize)
        
        parametersController.transitioningDelegate = panelTransition
        return parametersController
    }
    
    func chooseServiceType() {
        ModalRouter(source: self, destination: parametersController, modalPresentationStyle: .custom).route()
    }

    func needAddGuest() {
        self.presenter.needAddGuest()
    }

    func deleteGuest(at index: Int) {
        presenter.guestDidDelete(index: index)
    }

    func createPass(type: PassType) {
        self.presenter.createPass(type: type)
    }

    func showGuestsError() {
        presenter.showGuestsError()
    }

    func showNoGuestsError() {
        presenter.showNoGuestsError()
    }

    func showNoCarDataError() {
        presenter.showNoCarDataError()
    }

    func createParking(carNumber: String, guest: Guest, isResidentPay: Bool) {
        presenter.createParking(carNumber: carNumber, guest: guest, isResidentPay: isResidentPay)
    }

    func showParkingAlert() {
        presenter.showParkingAlert()
    }
}
