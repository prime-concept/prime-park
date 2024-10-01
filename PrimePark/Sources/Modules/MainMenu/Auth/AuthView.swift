import UIKit

protocol AuthViewDelegate: class {
    func onSelectCodeTap(currentCode: CountryCode)
    func onNextButtonTap(phone: String)
    func onResidentButtonTap(phone: String)
    func onCallButtonTap()
}

final class AuthView: UIView {
    private static var buttonStackHeight: CGFloat = 155

    private var alreadyPress = false
    private lazy var scrollView = UIScrollView()
    private lazy var containerView = UIView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.localize("auth.title")
        label.textColor = Palette.darkLightColor
        label.font = UIFont.primeParkFont(ofSize: 14)
        return label
    }()

    private lazy var enterPhoneView = EnterPhoneView(delegate: self)

    private lazy var authNumberPadView = AuthNumberPadView(delegate: self)

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(Localization.localize("auth.next"), for: .normal)
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)

        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.backgroundColor = Palette.goldColor.withAlphaComponent(0.5)

        button.addTarget(self, action: #selector(self.onNextButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 22.5

        #warning("Поменять при сборке")
        button.isEnabled = false

        return button
    }()

    private lazy var becomeResidentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localization.localize("auth.becomeResident"), for: .normal)
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(self.onBecomeResidentButtonTap), for: .touchUpInside)
        button.backgroundColor = Palette.darkLightColor.withAlphaComponent(0.2)
        button.layer.cornerRadius = 22.5
        return button
    }()

    private lazy var callButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localization.localize("auth.call"), for: .normal)
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(self.onCallButtonTap), for: .touchUpInside)
        button.backgroundColor = Palette.darkLightColor.withAlphaComponent(0.2)
        button.layer.cornerRadius = 22.5
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.nextButton,
                self.becomeResidentButton,
                self.callButton
            ]
        )
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()

    private lazy var termsTextView: UITextView = {
        let view = UITextView()

        view.backgroundColor = .clear
        view.delegate = self
        view.dataDetectorTypes = .link
        view.isEditable = false
        view.isSelectable = true
        view.isScrollEnabled = false
        view.tintColor = UIColor(hex: 0xeeeeee)

        let attributedString = NSMutableAttributedString(
            string: localizedWith("auth.terms"),
            attributes: [
                .foregroundColor: Palette.darkLightColor,
                .font: UIFont.primeParkFont(ofSize: 11)
            ]
        )

        attributedString.addAttributes(
            [.link: URL(string: "http://primeparkmanagement.ru/mp/offerta")],
            range: TermsRange.termsRange
        )

        attributedString.addAttributes(
            [.link: URL(string: "http://primeparkmanagement.ru/mp/offerta")],
            range: TermsRange.offerRange
        )

        view.attributedText = attributedString
        return view
    }()

    private weak var delegate: AuthViewDelegate?

    init(delegate: AuthViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onNextButtonTap() {
        if !self.alreadyPress {
            self.nextButton.setTitle(Localization.localize("auth.next.loading"), for: .normal)
            self.nextButton.startButtonLoadingAnimation()
            self.alreadyPress = true
            self.delegate?.onNextButtonTap(phone: self.enterPhoneView.phoneNumber)
        }
    }

    @objc
    private func onBecomeResidentButtonTap() {
        self.delegate?.onResidentButtonTap(phone: self.enterPhoneView.phoneNumber)
    }

    @objc
    private func onCallButtonTap() {
        self.delegate?.onCallButtonTap()
    }

    func select(countryCode: CountryCode) {
        self.enterPhoneView.select(countryCode: countryCode)
    }

    func unblockButton() {
        self.alreadyPress = false
    }

    func viewWillClose() {
        self.alreadyPress = false
    }
    
    func resetToDef() {
        self.nextButton.setTitle(Localization.localize("auth.next"), for: .normal)
        self.nextButton.endButtonLoadingAnimation(defaultTitle: "Далее")
    }
}

extension AuthView: Designable {
    func setupView() {
        self.backgroundColor = UIColor(hex: 0x252525)
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        [
            self.titleLabel,
            self.enterPhoneView,
            self.authNumberPadView,
            self.buttonsStackView,
            self.termsTextView
        ].forEach(self.containerView.addSubview)
    }

    func makeConstraints() {
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        self.containerView.snp.makeConstraints { make in
            make.width.edges.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        self.enterPhoneView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }

        self.authNumberPadView.snp.makeConstraints { make in
            make.top.equalTo(self.enterPhoneView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }

        self.buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(self.authNumberPadView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(Self.buttonStackHeight)
        }

        self.termsTextView.snp.makeConstraints { make in
            make.top.equalTo(self.buttonsStackView.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(50)
            make.bottom.equalToSuperview()
        }
    }
}

extension AuthView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}

extension AuthView: AuthNumberPadViewDelegate {
    func authNumberPad(didTap item: AuthNumberPadType) {
        switch item {
        case .delete:
            self.enterPhoneView.deleteLast()
        case .empty:
            break
        default:
            self.enterPhoneView.set(symbol: item.value ?? "")
        }
    }
}

extension AuthView: EnterPhoneViewDelegate {
    func onSelectCodeTap(currentCode: CountryCode) {
        self.delegate?.onSelectCodeTap(currentCode: currentCode)
    }

    func updateNextButtonAppearance(_ isHidden: Bool) {
        self.nextButton.backgroundColor = isHidden
            ? Palette.goldColor.withAlphaComponent(0.5)
            : Palette.goldColor
        self.nextButton.setTitleColor(
            isHidden ? UIColor.white.withAlphaComponent(0.5) : UIColor.white,
            for: .normal
        )
        self.nextButton.isEnabled = !isHidden
    }
}
