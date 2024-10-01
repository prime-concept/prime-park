import UIKit

protocol EnterPhoneViewDelegate: class {
    func onSelectCodeTap(currentCode: CountryCode)
    func updateNextButtonAppearance(_ isHidden: Bool)
}

final class EnterPhoneView: UIView, UITextFieldDelegate {

    private lazy var gestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onSelectCodeButtonTap))
        return gesture
    }()
    
    private lazy var codeSelectionView: UIView = {
        let view = LayerBackgroundView()
        view.backgroundColor = Palette.blackColor
        view.layer.cornerRadius = 25
        view.addGestureRecognizer(gestureRecognizer)
        return view
    }()

    private lazy var flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.primeParkFont(ofSize: 16)
        return label
    }()

    private lazy var selectCodeIconImageView = UIImageView(image: UIImage(named: "auth-select-code-icon"))

    private lazy var selectCodeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(self.onSelectCodeButtonTap), for: .touchUpInside)
        return button
    }()

    private lazy var phoneContainerView: UIView = {
        let view = LayerBackgroundView()
        view.backgroundColor = Palette.blackColor
        view.layer.cornerRadius = 25
        return view
    }()

    private lazy var phoneTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.font = UIFont.primeParkFont(ofSize: 16)
        textField.isUserInteractionEnabled = false
        #warning("Поменять при сборке")
        //textField.text = "9999999992"
        textField.text = selectedCode.maskDisplayable
        return textField
    }()

    private weak var delegate: EnterPhoneViewDelegate?

    private var selectedCode = CountryCode.defaultCountryCode {
        didSet {
            set(symbol: "")
        }
    }

    var phoneNumber: String {
        return "\(selectedCode.countryCodeDisplayable)\((self.phoneTextField.text ?? "").deleteMask())"
    }

    init(delegate: EnterPhoneViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()

        self.update()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onSelectCodeButtonTap() {
        self.delegate?.onSelectCodeTap(currentCode: self.selectedCode)
    }

    private func update() {
        self.flagImageView.image = self.selectedCode.flagImage
        self.codeLabel.text = self.selectedCode.countryCodeDisplayable
    }

    func select(countryCode: CountryCode) {
        self.selectedCode = countryCode
        self.update()
    }

    func set(symbol: String) {
        var textWithoutMask = (self.phoneTextField.text ?? "").deleteMask()
//        if textWithoutMask.count == 10 { return }
        textWithoutMask += symbol
        let phoneWithMask = textWithoutMask.addPhoneMask(country: selectedCode)
        self.phoneTextField.text = phoneWithMask

        self.delegate?.updateNextButtonAppearance(phoneWithMask.contains("_"))
    }

    func deleteLast() {
        var textWithoutMask = (self.phoneTextField.text ?? "").deleteMask()
        if textWithoutMask.isEmpty {
            return
        }

        textWithoutMask.removeLast()
        let text = textWithoutMask.addPhoneMask(country: selectedCode)
        self.phoneTextField.text = text

        self.delegate?.updateNextButtonAppearance(text.contains("_"))
    }
}

extension EnterPhoneView: Designable {
    func addSubviews() {
        [self.codeSelectionView, self.phoneContainerView].forEach(self.addSubview)
        [
            self.flagImageView,
            self.codeLabel,
            self.selectCodeIconImageView,
            self.selectCodeButton
        ].forEach(self.codeSelectionView.addSubview)

        self.phoneContainerView.addSubview(self.phoneTextField)
    }

    func makeConstraints() {
        self.codeSelectionView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 101, height: 50))
        }

        self.phoneContainerView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(self.codeSelectionView.snp.trailing).offset(10)
            make.size.equalTo(CGSize(width: 164, height: 50))
        }

        self.flagImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 16, height: 12))
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }

        self.codeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.flagImageView.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }

        self.selectCodeIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 8, height: 4.5))
            make.centerY.equalToSuperview()
        }

        self.selectCodeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-5)
            make.top.bottom.equalToSuperview().inset(5)
            make.width.equalTo(25)
        }

        self.phoneTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }
}
