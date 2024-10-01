import UIKit

protocol SecurityViewDelegate: AnyObject {
    func onCallbackButtonTap()
    func onWriteInChatButtonTap()
    func onSecurityCallButtonTap()
    func onCallSecurityInRoomButtonTap()
    func onCallSecurityInParkButtonTap()
    func onCallSecurityInLobbyButtonTap()
}

final class SecurityView: UIView {
    private lazy var closeButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "hide_view_rectangle_button"))
        imageView.image?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()

    private lazy var titleLabel: LocalizableLabel = {
        let label = LocalizableLabel()
        label.localizedKey = "security.title"
        label.font = UIFont.primeParkFont(ofSize: 16)
        label.textColor = UIColor.white
        return label
    }()

    private lazy var divideView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x545458).withAlphaComponent(0.65)
        return view
    }()

    private lazy var descriptionLabel: LocalizableLabel = {
        let label = LocalizableLabel()
        label.localizedKey = "security.description"
        label.font = UIFont.primeParkFont(ofSize: 14)
        label.textColor = UIColor.white
        label.numberOfLines = 3
        return label
    }()

    private lazy var callbackButton: LocalizableButton = {
        let button = LocalizableButton(type: .system)
        button.backgroundColor = UIColor(hex: 0x828082).withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(self.onCallbackButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 27.5
        button.setImage(UIImage(named: "callback")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    private lazy var callbackLabel: LocalizableLabel = {
        let label = LocalizableLabel()
        label.localizedKey = "security.callback"
        label.font = UIFont.primeParkFont(ofSize: 12)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var callbackView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var writeInChatButton: LocalizableButton = {
        let button = LocalizableButton(type: .system)
        button.backgroundColor = UIColor(hex: 0x828082).withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(self.onWriteInChatButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 27.5
        button.setImage(UIImage(named: "write_in_chat")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    private lazy var writeInChatLabel: LocalizableLabel = {
        let label = LocalizableLabel()
        label.localizedKey = "security.writeInChat"
        label.font = UIFont.primeParkFont(ofSize: 12)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var writeInChatView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var securityCallButton: LocalizableButton = {
        let button = LocalizableButton(type: .system)
        button.backgroundColor = UIColor(hex: 0x828082).withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(self.onSecurityCallButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 27.5
        button.setImage(UIImage(named: "security_call")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    private lazy var securityCallLabel: LocalizableLabel = {
        let label = LocalizableLabel()
        label.localizedKey = "security.securityCall"
        label.font = UIFont.primeParkFont(ofSize: 12)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var securityCallView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var callButtonsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.callbackView,
                self.writeInChatView,
                self.securityCallView
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 40
        return stackView
    }()

    private lazy var callSecurityLabel: LocalizableLabel = {
        let label = LocalizableLabel()
        label.localizedKey = "security.callSecurity.text"
        label.font = UIFont.primeParkFont(ofSize: 16)
        label.textColor = UIColor.white
        return label
    }()

    private lazy var callSecurityInRoomButton: LocalizableButton = {
        let button = LocalizableButton(type: .system)
        let number = self.roomNumber.isEmpty ? "102A" : self.roomNumber
        button.localizedKey = "security.callSecurityButton.inRoom"
        button.additionText = number
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)

        button.backgroundColor = UIColor(hex: 0xCC2A21)
        button.setTitleColor(UIColor.white, for: .normal)

        button.addTarget(self, action: #selector(self.onCallSecurityInRoomButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 22.5

        return button
    }()

    private lazy var callSecurityInParkButton: LocalizableButton = {
        let button = LocalizableButton(type: .system)

        button.localizedKey = "security.callSecurityButton.inPark"
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)

        button.backgroundColor = UIColor(hex: 0x828082).withAlphaComponent(0.2)
        button.setTitleColor(UIColor.white, for: .normal)

        button.addTarget(self, action: #selector(self.onCallSecurityInParkButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 22.5

        return button
    }()

    private lazy var callSecurityInLobbyButton: LocalizableButton = {
        let button = LocalizableButton(type: .system)

        button.localizedKey = "security.callSecurityButton.inLobby"
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)

        button.backgroundColor = UIColor(hex: 0x828082).withAlphaComponent(0.2)
        button.setTitleColor(UIColor.white, for: .normal)

        button.addTarget(self, action: #selector(self.onCallSecurityInLobbyButtonTap), for: .touchUpInside)
        button.layer.cornerRadius = 22.5

        return button
    }()

    private lazy var callSecurityButtonsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.callSecurityInParkButton,
                self.callSecurityInLobbyButton
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }()

    private weak var delegate: SecurityViewDelegate?
    private var roomNumber: String

    init(delegate: SecurityViewDelegate?, roomNumber: String) {
        self.delegate = delegate
        self.roomNumber = roomNumber
        super.init(frame: .zero)
        self.setupView()
        self.addSubviews()
        self.makeConstraints()
        changeAccess(LocalAuthService.shared.apartment?.getRole)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onCallbackButtonTap() {
        self.delegate?.onCallbackButtonTap()
    }

    @objc
    private func onWriteInChatButtonTap() {
        self.delegate?.onWriteInChatButtonTap()
    }

    @objc
    private func onSecurityCallButtonTap() {
        self.delegate?.onSecurityCallButtonTap()
    }

    @objc
    private func onCallSecurityInRoomButtonTap() {
        self.delegate?.onCallSecurityInRoomButtonTap()
    }

    @objc
    private func onCallSecurityInParkButtonTap() {
        self.delegate?.onCallSecurityInParkButtonTap()
    }

    @objc
    private func onCallSecurityInLobbyButtonTap() {
        self.delegate?.onCallSecurityInLobbyButtonTap()
    }
}

extension SecurityView: Designable {
    func setupView() {
        self.backgroundColor = Palette.darkColor
    }

    func addSubviews() {
        [
            self.callbackButton,
            self.callbackLabel
        ].forEach(self.callbackView.addSubview)
        [
            self.writeInChatButton,
            self.writeInChatLabel
        ].forEach(self.writeInChatView.addSubview)
        [
            self.securityCallButton,
            self.securityCallLabel
        ].forEach(self.securityCallView.addSubview)

        [
            self.closeButtonImageView,
            self.titleLabel,
            self.divideView,
            self.descriptionLabel,
            self.callButtonsStackView,
            self.callSecurityLabel,
            self.callSecurityInRoomButton,
            self.callSecurityButtonsStackView
        ].forEach(self.addSubview)
    }
    //swiftlint:disable function_body_length
    func makeConstraints() {
        self.closeButtonImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(23)
            make.centerX.equalToSuperview()
        }

        self.divideView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(55)
        }

        self.descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().inset(16)
            make.top.equalTo(self.divideView.snp.bottom).offset(20)
        }

        self.callButtonsStackView.snp.makeConstraints { make in
            //make.height.equalTo(95)
            make.leading.trailing.equalToSuperview().inset(50)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
        }

        self.callSecurityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.callButtonsStackView.snp.bottom).offset(40)
        }

        self.callSecurityInRoomButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(self.callSecurityLabel.snp.bottom).offset(15)
        }

        self.callSecurityButtonsStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(self.callSecurityInRoomButton.snp.bottom).offset(5)
        }

        self.callSecurityInParkButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.top.bottom.equalToSuperview().offset(1)
        }

        self.callSecurityInLobbyButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.top.bottom.equalToSuperview().offset(1)
        }

        self.callbackButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(1)
        }

        self.callbackLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.callbackButton.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(1)
            make.width.equalTo(self.callbackButton.snp.width).offset(5)//
        }

        self.writeInChatButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(1)
        }

        self.writeInChatLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.callbackButton.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(1)
            make.width.equalTo(self.writeInChatButton.snp.width)
        }

        self.securityCallButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(1)
        }

        self.securityCallLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.callbackButton.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(1)
            make.width.equalTo(self.securityCallButton.snp.width)
        }
    }
}

extension SecurityView {
    func changeHidden(_ isHidden: Bool) {
        self.callSecurityLabel.isHidden = isHidden
        self.callSecurityInRoomButton.isHidden = isHidden
        self.callSecurityButtonsStackView.isHidden = isHidden
    }
    func changeAccess(_ role: Role?) {
        guard let role = role else { return }
        switch role {
        case .resident:
            changeHidden(false)
        case .cohabitant:
            changeHidden(false)
        case .brigadier:
            changeHidden(true)
        case .guest:
            changeHidden(true)
        }
    }
}
