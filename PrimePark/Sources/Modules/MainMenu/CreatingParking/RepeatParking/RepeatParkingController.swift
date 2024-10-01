protocol RepeatParkingControllerProtocol: ModalRouterSourceProtocol {
    func closeController()
}

extension Notification.Name {
    static let parkingControllerDidClose = Notification.Name("parkingControllerDidClose")
}

final class RepeatParkingController: UIViewController {
    private lazy var passView: RepeatParkingView = {
        var view = Bundle.main.loadNibNamed("RepeatParkingView", owner: nil, options: nil)?.first as? RepeatParkingView ?? RepeatParkingView()
        return view
    }()

    private let presenter: RepeatParkingPresenterProtocol
    private let parking: Parking
    private var infoView: InfoView?

    init(
		presenter: RepeatParkingPresenterProtocol,
		parking: Parking
	) {
        self.presenter = presenter
        self.parking = parking
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.passView
        self.passView.addDelegate(self, parking: parking)
        passView.commonInit()
    }
	
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .passControllerDidClose, object: nil)
    }
}

extension RepeatParkingController: RepeatParkingControllerProtocol {
    func closeController() {
        self.dismiss(animated: false, completion: nil)
    }
}

extension RepeatParkingController: RepeatParkingViewProtocol {
	func repeatParking() {
		self.presenter.repeatParking()
		dismiss(animated: false, completion: nil)
	}
}

extension RepeatParkingController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}
