import UIKit

final class HomeItemView: UIView {
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var titleLabel: LocalizableLabel = {
        let label = LocalizableLabel()
        label.font = UIFont.primeParkFont(ofSize: 11)
        label.textColor = .white
        return label
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private var type: HomeItemType? {
        didSet {
            self.titleLabel.localizedKey = self.type?.title
            self.iconImageView.image = self.type?.image
        }
    }

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

    func setup(with type: HomeItemType) {
        self.type = type
    }
}

extension HomeItemView: Designable {
    func setupView() {
        self.backgroundColor = UIColor(hex: 0x353433)
        self.layer.cornerRadius = 20
    }

    func addSubviews() {
        [self.containerView].forEach(self.addSubview)
        [self.iconImageView, self.titleLabel].forEach(self.containerView.addSubview)
    }

    func makeConstraints() {

        self.containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
        }

        self.iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.titleLabel.snp.top).offset(-2)
        }
    }
}
