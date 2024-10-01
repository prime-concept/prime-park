protocol ResidentListControllerProtocol: class, ModalRouterSourceProtocol, PushRouterSourceProtocol {
    func residentsDidLoad(_ array: [Resident])
    func showAlert(_ alert: UIAlertController)
}

final class ResidentListController: UIViewController {
    private lazy var residentListView: ResidentListView = {
        var view = Bundle.main.loadNibNamed("ResidentListView", owner: nil, options: nil)?.first as? ResidentListView ?? ResidentListView()
        return view
    }()

     private let presenter: ResidentListPresenterProtocol

    init(presenter: ResidentListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.residentListView
        self.residentListView.addDelegate(self)
        residentListView.commonInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.deleteBlurEffect), name: NSNotification.Name(rawValue: "PassDetailControllerDidClose"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        residentListView.isLoaded = false
    }
}

extension ResidentListController: ResidentListViewProtocol {
    func back() {
        self.navigationController?.popViewController(animated: true)
    }

    func info() {
        presenter.showInfo()
    }

    func addResident() {
        presenter.addResident()
    }
}

extension ResidentListController: ResidentListControllerProtocol {
    func residentsDidLoad(_ array: [Resident]) {
        self.residentListView.addResidents(array)
    }

    func showAlert(_ alert: UIAlertController) {
        present(module: alert)
    }
}
