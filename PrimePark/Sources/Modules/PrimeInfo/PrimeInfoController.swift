final class PrimeInfoController: UIViewController {
    private lazy var primeInfoView: PrimeInfoView = {
        var view = Bundle.main.loadNibNamed("PrimeInfoView", owner: nil, options: nil)?.first as? PrimeInfoView ?? PrimeInfoView()
        return view
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.primeInfoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.primeInfoView.commoninit()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
