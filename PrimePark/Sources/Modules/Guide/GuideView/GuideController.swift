final class GuideController: UIViewController {
    private lazy var guideView: GuideView = {
        let view = Bundle.main.loadNibNamed("GuideView", owner: nil, options: nil)?.first as? GuideView ?? GuideView(delegate: self)
        return view
    }()

    private let token: String

    init(token: String) {
            self.token = token
            super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = guideView
        guideView.addDelegate(delegate: self)
        guideView.addData(token: token)
        guideView.commonInit()
    }
}

extension GuideController: GuideViewProtocol {
}
