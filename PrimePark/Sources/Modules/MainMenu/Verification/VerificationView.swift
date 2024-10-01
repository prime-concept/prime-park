import UIKit

protocol VerificationViewDelegate: class {
    func onNextButtonTap(code: String)
    func onSendButtonTap()
}

final class VerificationView: UIView {
    private static let sendDisableTitleColor = UIColor.white.withAlphaComponent(0.2)
    private static let sendTitleColor = UIColor.white
    private static let defaultTime = 60

    private let maxCodeCount = 5

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.localize("auth.verificationTitle")
        label.font = UIFont.primeParkFont(ofSize: 14)
        label.textColor = Palette.darkLightColor
        return label
    }()

    private lazy var codeContainerView: UIView = {
        let view = LayerBackgroundView()
        view.backgroundColor = Palette.blackColor
        view.layer.cornerRadius = 25
        return view
    }()

    lazy var codeTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.primeParkFont(ofSize: 16)
        textField.textColor = .white
        textField.textAlignment = .center
        textField.addTarget(self, action: #selector(textFieldEditingDidChange(_:)), for: .editingChanged)
        textField.keyboardType = .numberPad
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
        #warning("Поменять при сборке")
        textFieldEditingDidChange(textField)
        textField.delegate = self
        return textField
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(Localization.localize("auth.next"), for: .normal)
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)

        button.backgroundColor = Palette.goldColor.withAlphaComponent(0.5)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)

        button.addTarget(self, action: #selector(self.onNextButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 22.5

        #warning("Поменять при сборке")
        button.isEnabled = false

        return button
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localization.localize("auth.retry"), for: .normal)
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)
        button.backgroundColor = Palette.darkLightColor.withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(self.onSendButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 22.5
        button.setTitleColor(UIColor.white.withAlphaComponent(0.2), for: .normal)
        return button
    }()

    private var time: Int = defaultTime

    weak var timer: Timer?

    private weak var delegate: VerificationViewDelegate?

    init(delegate: VerificationViewDelegate?) {
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
        self.nextButton.setTitle(Localization.localize("auth.next.loading"), for: .normal)
//        startAnimatingButton()
        self.nextButton.startButtonLoadingAnimation()
        self.nextButton.isEnabled = false
        self.codeTextField.isEnabled = false
        self.delegate?.onNextButtonTap(code: self.codeTextField.text ?? "")
        self.codeTextField.text = ""
    }

    @objc
    private func onSendButtonTap() {
        self.delegate?.onSendButtonTap()
    }

    @objc
    private func textFieldEditingDidChange(_ textField: UITextField) {
        guard let text = textField.text?.deleteMask() else {
            return
        }

        self.nextButton.backgroundColor = text.count == maxCodeCount
            ? Palette.goldColor
            : Palette.goldColor.withAlphaComponent(0.5)
        self.nextButton.setTitleColor(
            text.count == maxCodeCount ? UIColor.white : UIColor.white.withAlphaComponent(0.5),
            for: .normal
        )
        self.nextButton.isEnabled = text.count == maxCodeCount

        let maskText = text.addCodeMask()

        let attributedString = NSMutableAttributedString(string: maskText)
        attributedString.addAttribute(
            .kern,
            value: CGFloat(8.0),
            range: NSRange(location: 0, length: attributedString.length)
        )
        if !(textField.text?.matches("[0-9]") ?? false) {
            textField.attributedPlaceholder = attributedString
            textField.attributedText = nil
        } else {
            textField.attributedText = attributedString
        }
        
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: text.count) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }

    func closeKeyboard() {
        self.codeTextField.resignFirstResponder()
    }
    
    func resetToDef() {
        self.nextButton.setTitle(Localization.localize("auth.retry"), for: .normal)
        self.codeTextField.isEnabled = true
        self.nextButton.endButtonLoadingAnimation(defaultTitle: "Далее")
    }

    private func startTimer() {
        self.sendButton.isEnabled = false
        guard self.timer == nil else {
            return
        }

        self.timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.didTimerTick),
            userInfo: nil,
            repeats: true
        )
        self.didTimerTick()
    }

    @objc
    private func didTimerTick() {
        self.time -= 1

        self.sendButton.setTitleColor(Self.sendDisableTitleColor, for: .normal)

        self.sendButton.setTitle("\(Localization.localize("auth.retryTimer")) \(self.time)", for: .normal)

        if self.time == 0 {
            self.stopTimer()
            return
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
        self.time = Self.defaultTime

        self.sendButton.setTitleColor(Self.sendTitleColor, for: .normal)
        self.sendButton.setTitle(Localization.localize("auth.retry"), for: .normal)
        self.sendButton.isEnabled = true
    }
}

extension VerificationView: UITextFieldDelegate {
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textWithoutMask = (textField.text ?? "").deleteMask()
        if textWithoutMask.count == maxCodeCount {
            if let textRange = Range(range, in: textWithoutMask) {
            let updatedText = textWithoutMask.replacingCharacters(in: textRange, with: string)
                return updatedText.count <= maxCodeCount
            }
        }
        return true
    }
}

extension VerificationView: Designable {
    func setupView() {
        self.backgroundColor = UIColor(hex: 0x252525)

        self.startTimer()
    }

    func addSubviews() {
        [
            self.titleLabel,
            self.codeContainerView,
            self.nextButton,
            self.sendButton
        ].forEach(self.addSubview)

        self.codeContainerView.addSubview(self.codeTextField)
    }

    func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35)
            make.centerX.equalToSuperview()
        }

        self.codeContainerView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 275, height: 50))
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }

        self.nextButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 275, height: 45))
            make.top.equalTo(self.codeContainerView.snp.bottom).offset(45)
            make.centerX.equalToSuperview()
        }

        self.sendButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 275, height: 45))
            make.top.equalTo(self.nextButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        self.codeTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
}
