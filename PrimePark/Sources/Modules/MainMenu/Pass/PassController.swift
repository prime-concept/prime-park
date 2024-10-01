protocol PassControllerProtocol: ModalRouterSourceProtocol {
    func closeController()
}

extension Notification.Name {
    static let passControllerDidClose = Notification.Name("passControllerDidClose")
}

final class PassController: UIViewController {
    private lazy var passView: PassView = {
        var view = Bundle.main.loadNibNamed("PassView", owner: nil, options: nil)?.first as? PassView ?? PassView()
        return view
    }()

    private let presenter: PassPresenterProtocol
    private let pass: IssuePass
    private var infoView: InfoView?

    init(presenter: PassPresenterProtocol, pass: IssuePass) {
        self.presenter = presenter
        self.pass = pass
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.passView
        self.passView.addDelegate(self, pass: pass)
        passView.commonInit()
    }
	
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .passControllerDidClose, object: nil)
    }
}

extension PassController: PassControllerProtocol {
    func closeController() {
        self.dismiss(animated: false, completion: nil)
    }
}

extension PassController: PassViewProtocol {
    func repeatPass() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NeedRepeatPass"), object: nil)
        dismiss(animated: false, completion: nil)
    }

    func revokePass() {
        presenter.revokePass()
    }
}

extension PassController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}
