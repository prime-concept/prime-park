final class PassInfoController: UIViewController {
    private lazy var passInfoView: PassInfoView = {
        var view = Bundle.main.loadNibNamed("PassInfoView", owner: nil, options: nil)?.first as? PassInfoView ?? PassInfoView()
        return view
    }()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = self.passInfoView
        self.passInfoView.addDelegate(self)
        passInfoView.commonInit()
    }
}

extension PassInfoController: LawInfoViewProtocol {
}
