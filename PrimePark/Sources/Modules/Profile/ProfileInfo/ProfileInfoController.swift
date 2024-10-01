final class ProfileInfoController: UIViewController {
    private lazy var profileInfoView: ProfileInfoView = {
        var view = Bundle.main.loadNibNamed("ProfileInfoView", owner: nil, options: nil)?.first as? ProfileInfoView ?? ProfileInfoView()
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
        self.view = self.profileInfoView
        self.profileInfoView.addDelegate(self)
        profileInfoView.commonInit()
    }
}

extension ProfileInfoController: ProfileInfoViewProtocol {
}
