final class PrimeInfoView: UIView {
    @IBOutlet private weak var backgroundImage: UIImageView!

    private let darkColor = UIColor(hex: 0x121212)

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.0, y: 0.9)
        layer.endPoint = CGPoint(x: 0.0, y: 0.0)

        layer.colors = [
            self.darkColor.withAlphaComponent(0).cgColor,
            self.darkColor.withAlphaComponent(1).cgColor
        ]

         return layer
    }()

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

    func commoninit() {
        self.gradientLayer.frame = self.backgroundImage.frame
        self.backgroundImage.layer.mask = self.gradientLayer//insertSublayer(self.gradientLayer, at: 0)
    }
}
