import UIKit

final class AuthNumberPadItemView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.primeParkFont(ofSize: 29, weight: .light)
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var type: AuthNumberPadType? {
        didSet {
            self.makeItem()

            self.titleLabel.text = self.type?.value
            self.imageView.image = self.type?.image
        }
    }

    private func makeItem() {
        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    func setup(with type: AuthNumberPadType) {
        self.type = type
    }
}

extension AuthNumberPadItemView: Designable {
    func setupView() {
        self.layer.cornerRadius = 27.5

        switch self.type {
        case .empty, .delete:
            break
        default:
            self.backgroundColor = Palette.darkLightColor.withAlphaComponent(0.2)
        }
    }

    func addSubviews() {
        switch self.type {
        case .delete:
            self.addSubview(self.imageView)
        case .empty:
            break
        default:
            self.addSubview(self.titleLabel)
        }
    }

    func makeConstraints() {
        switch self.type {
        case .delete:
            self.imageView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 23, height: 17))
                make.centerX.centerY.equalToSuperview()
            }
        case .empty:
            break
        default:
            self.titleLabel.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
            }
        }
    }
}
