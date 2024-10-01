protocol ModerationViewProtocol: class {
    func becomeResident()
    func callToMC()
    func changeNumber()
}

final class ModerationView: UIView {
    private weak var delegate: ModerationViewProtocol?

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

    func addDelegate(_ delegate: ModerationViewProtocol) {
        self.delegate = delegate
    }

    // MARK: - Actions

    @IBAction private func changeNumber(_ sender: Any) {
        delegate?.changeNumber()
    }

    @IBAction private func becomeResident(_ sender: Any) {
        delegate?.becomeResident()
    }

    @IBAction private func callToMC(_ sender: Any) {
        delegate?.callToMC()
    }
}
