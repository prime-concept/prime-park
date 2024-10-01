protocol ProfileInfoViewProtocol: class {
}

final class ProfileInfoView: UIView {
    private weak var delegate: ProfileInfoViewProtocol?

    // MARK: - Initialization

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Public API

    func commonInit() {
    }

    func addDelegate(_ delegate: ProfileInfoViewProtocol) {
        self.delegate = delegate
    }
}
