import UIKit
//swiftlint:disable trailing_whitespace
protocol ParkingListControllerProtocol: AnyObject, ModalRouterSourceProtocol, PushRouterSourceProtocol {
    func setOneTimeParking(list: [Parking])
    func setPermanentParking(list: [Parking])
    func changeAccess(_ role: Role)
    
    //permanent section
    
    func createPermanent()
    func setService(service: CreateParkingIssues)
    func setCarsAmount(amount: String)
    func setMonthAmount(amount: String)
    
    //callback
    
    func createPermanentDone()
    
    //valet section
    var viewProtocol: ParkingListViewProtocol { get }
}

final class ParkingListController: UIViewController {
    
    private lazy var parkingListView: ParkingListView = {
        var view = Bundle.main.loadNibNamed("ParkingListView", owner: nil, options: nil)?.first as? ParkingListView ?? ParkingListView()
        return view
    }()
    
    let panelTransition = PanelTransition()
    private lazy var parametersController = setupParamters()

    private let presenter: ParkingListPresenterProtocol
    private var isIGive: Bool = true
    
    private let gesture = UILongPressGestureRecognizer()

    init(presenter: ParkingListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = parkingListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gesture.addTarget(self, action: #selector(gestureHandler))
        parkingListView.valetTableView.addGestureRecognizer(gesture)
        
        parkingListView.addDelegate(self)
        parkingListView.commonInit()
        parkingListView.setButtonEnabled(self.presenter.canCreateParking())
        
        //presenter.getValetCards(cardType: .ticket)
        presenter.getAllValetCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc
    func gestureHandler(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            let tapLocation = recognizer.location(in: self.parkingListView.valetTableView)
            if let tapIndexPath = self.parkingListView.valetTableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.parkingListView.valetTableView.cellForRow(at: tapIndexPath) as? ValetCell {
                    //AlertService.presentAlert(title: tappedCell.data?.ticket ?? "-")
                    
                    let ticket = tappedCell.data?.ticket ?? "-"
                    
                    let alert = UIAlertController(title: ticket, message: "Enter new title for ticket", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "cancel", style: .cancel))
                    
                    let alertOkAction = UIAlertAction(title: "ok", style: .default) { _ in
                        if let firstTextfield = alert.textFields?.first,
                           let text = firstTextfield.text,
                           !text.isEmpty {
                            self.presenter.setNewTicketTitle(tn: ticket, newTitle: text)
                        }
                    }
                    
                    alert.addAction(alertOkAction)
                    alert.addTextField()
                    
                    present(alert, animated: true)
                }
            }
        }
    }
}

extension ParkingListController: ParkingListViewDelegate {
	func repeatParking(_ parking: Parking) {
		guard parking.type == .onetime else {
			return
		}

		let parkingAssembly = RepeatParkingAssembly(
			source: self.presenter,
			authService: LocalAuthService(),
			parking: parking,
			passID: 0
		)

		ModalRouter(
			source: self,
			destination: parkingAssembly.make(),
			modalPresentationStyle: .popover
		).route()
	}

    func back() {
        self.navigationController?.popViewController(animated: true)
    }

    func newIssue() {
        self.presenter.createNewIssue()
    }

    func showDetail(for parking: ParkingTicket) {
        //let valetTimerController = ValetTimerAssembly(parkingTicket: parking, state: .existing).make()
        
        //if parking.cardType == .ticket {
            let valetOrderController = ValetOrderAssembly(parkingTicket: parking, isExistingCard: true).make()
            
            PushRouter(
                source: self,
                destination: valetOrderController
            ).route()
            
            return
        //}
    }

    func showInfo() {
        presenter.showInfo()
    }
    
    private func setupParamters() -> ParametersController {
        let content = [
            ParametersData(name: "Valet абонемент", isSelected: false),
            ParametersData(name: "Private абонемен", isSelected: false)
        ]
        
        parametersController = ParametersAssembly(content: content).makeAsInheritor

        parametersController.choosenClosure = { [weak self] (content, row) in
            self?.parkingListView.setServiceType(name: content.name)
            self?.presenter.setService(
                service: CreateParkingIssues(rawValue: content.name) ?? .privateParking
            )
        }
        
        panelTransition.currentPresentation = .dynamic(height: parametersController.dynamicSize)
        
        parametersController.transitioningDelegate = panelTransition
        return parametersController
    }
    
    func chooseServiceType() {
        ModalRouter(source: self, destination: parametersController, modalPresentationStyle: .custom).route()
    }
    
    //permanent section
    func createPermanent() {
        
        if presenter.getServiceType == .privateValetParking {
            let abonementValetController = ValetModalAbonementAssembly().make()
            
            panelTransition.currentPresentation = .dynamic(height: 300)
            abonementValetController.transitioningDelegate = panelTransition
            
            ModalRouter(
                source: self,
                destination: abonementValetController,
                modalPresentationStyle: .custom
            ).route()
            
            return
        }
        
        parkingListView.createIssueButton.startButtonLoadingAnimation()
        presenter.createPermanent()
    }
}

extension ParkingListController: ParkingListControllerProtocol {
    var viewProtocol: ParkingListViewProtocol {
        return parkingListView
    }
    
    func createPermanentDone() {
        parkingListView.permanentDone()
    }
    
    func setOneTimeParking(list: [Parking]) {
        parkingListView.addOnetimeParkingArray(list)
    }

    func setPermanentParking(list: [Parking]) {
        parkingListView.addPermanentParkingArray(list)
    }
    
    func changeAccess(_ role: Role) {
        parkingListView.changeAccess(role)
    }
    
    // permanent section
    func setMonthAmount(amount: String) {
        presenter.setMonthAmount(amount: amount)
    }
    
    func setCarsAmount(amount: String) {
        presenter.setCarsAmount(amount: amount)
    }
    
    func setService(service: CreateParkingIssues) {
        presenter.setService(service: service)
    }
    
    func warningAlert() {
        presenter.showWarningAlert()
    }
    
    func toValetOrderScreen(type: ParkingTicket.CardType) {
        PushRouter(
            source: self,
            destination: ValetOrderAssembly(parkingTicket: ParkingTicket(cardType: type)).make()
        ).route()
    }
}
