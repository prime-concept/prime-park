final class ModerationController: UIViewController {
    private lazy var moderationView: ModerationView = {
        var view = Bundle.main.loadNibNamed("ModerationView", owner: nil, options: nil)?.first as? ModerationView ?? ModerationView()
        return view
    }()

    var presenter: PassPresenterProtocol & ModerationPresenerProtocol
    private let pass: Pass?

    init(presenter: PassPresenterProtocol & ModerationPresenerProtocol, pass: Pass?) {
        self.presenter = presenter
        self.pass = pass
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.moderationView
        self.moderationView.addDelegate(self)
        moderationView.commonInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension ModerationController: ModerationViewProtocol {
    // swiftlint:disable force_unwrapping
    func becomeResident() {
        let url = URL(string: "https://primepark.ru")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func callToMC() {
        presenter.callToMC()
    }

    func changeNumber() {
        navigationController?.popToRootViewController(animated: true)
    }
}
