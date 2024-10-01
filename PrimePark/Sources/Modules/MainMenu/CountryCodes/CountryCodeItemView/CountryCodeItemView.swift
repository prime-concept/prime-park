import UIKit

final class CountryCodeItemView: UIView {
    private static let defaultColor = Palette.darkLightColor
    private static let selectedColor = UIColor.white

    private lazy var flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Self.defaultColor
        label.font = UIFont.primeParkFont(ofSize: 16)
        return label
    }()

    private lazy var countryNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Self.defaultColor
        label.font = UIFont.primeParkFont(ofSize: 16)
        return label
    }()

    private lazy var selectedIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "check-mark"))
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.darkLightColor.withAlphaComponent(0.2)
        return view
    }()

    var flag: UIImage? {
        didSet {
            self.flagImageView.image = self.flag
        }
    }

    var code: String? {
        didSet {
            self.codeLabel.text = self.code
        }
    }

    var countryName: String? {
        didSet {
            self.countryNameLabel.text = self.countryName
        }
    }

    var isSelected: Bool = false {
        didSet {
            self.selectedIconImageView.isHidden = !self.isSelected
        }
    }

    init() {
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateAppearance() {
        self.codeLabel.textColor = self.isSelected ? Self.selectedColor : Self.defaultColor
        self.countryNameLabel.textColor = self.isSelected ? Self.selectedColor : Self.defaultColor
    }
}

extension CountryCodeItemView: Designable {
    func setupView() {
    }

    func addSubviews() {
        [
            self.flagImageView,
            self.codeLabel,
            self.countryNameLabel,
            self.selectedIconImageView,
            self.lineView
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.flagImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 16, height: 12))
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(25)
        }

        self.codeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(self.flagImageView.snp.trailing).offset(10)
        }

        self.countryNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(self.flagImageView.snp.trailing).offset(81)
        }

        self.selectedIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-19)
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalToSuperview()
        }

        self.lineView.snp.makeConstraints { make in
            make.top.equalTo(self.flagImageView.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
