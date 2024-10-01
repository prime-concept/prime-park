import SnapKit
import UIKit

final class PrimeParkBackgroundView: UIView {
    private static let darkColor = UIColor(hex: 0x121212)

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "prime-park-background-image"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0.25)
        layer.endPoint = CGPoint(x: 0.5, y: 0.95)

        layer.colors = [
            Self.darkColor.withAlphaComponent(0).cgColor,
            Self.darkColor.withAlphaComponent(1).cgColor
        ]

         return layer
    }()

    init() {
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradientLayer.frame = self.backgroundImageView.frame
    }
}

extension PrimeParkBackgroundView: Designable {
    func setupView() {
        self.backgroundColor = Self.darkColor

        self.backgroundImageView.layer.insertSublayer(self.gradientLayer, at: 0)
    }

    func addSubviews() {
        self.addSubview(self.backgroundImageView)
    }

    func makeConstraints() {
        self.backgroundImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.backgroundImageView.snp.width).multipliedBy(0.89)
        }
    }
}
