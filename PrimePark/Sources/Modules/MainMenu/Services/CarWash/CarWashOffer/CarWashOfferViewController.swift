import Foundation
import SnapKit
import UIKit

final class CarWashOfferViewController: UIViewController {
    private let offerLink: String = "https://primeparking.ru/ofertamoyka"
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldPrimeParkFont(ofSize: 16)
        label.text = localizedWith("carWash.dateAndTime.title")
        label.textColor = .white
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()

    private lazy var bottomSeparatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()

    private lazy var confirmationLabel: UILabel = {
        var label = UILabel()
        label.text = localizedWith("carWash.offer.confirm")
        label.textColor = .white
        label.font = UIFont.primeParkFont(ofSize: 16)
        return label
    }()

    private lazy var buttonsStackView: UIStackView = {
        let buttonStack = UIStackView(arrangedSubviews: [self.closeButton, self.continueButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 5
        return buttonStack
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 22
        button.setTitle("Отменить", for: .normal)
        return button
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Palette.mainColor
        button.layer.cornerRadius = 22
        button.setTitle(localizedWith("auth.next"), for: .normal)
        return button
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.darkColor
        view.layer.cornerRadius = 20
        return view
    }()

    private(set) lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = Palette.mainColor
        switcher.tintColor = .black
        switcher.backgroundColor = .clear
        switcher.thumbTintColor = .white
        switcher.addTarget(self, action: #selector(self.onSwitcherValueChange), for: .valueChanged)
        return switcher
    }()

    private lazy var offerTermView = with(TermView()) { view in
        let consentText = localizedWith("carWash.offer.text")
        let personalDataText = localizedWith("carWash.offer.link")

        let attributedConsentText = consentText.attributed()
            .foregroundColor(UIColor.white)
            .primeFont(ofSize: 14, lineHeight: 18)
            .alignment(.center)
            .string()
        let attributedPersonalDataText = personalDataText.attributed()
            .primeFont(ofSize: 14, lineHeight: 18)
            .hyperLink(self.offerLink)
            .alignment(.center)
            .string()

        view.onLinkTap = { _ in
            self.presentPrivacyPolicyViewController()
        }

        view.setupTerms(with: attributedConsentText + attributedPersonalDataText)
    }

    var onCloseCompletion: (() -> Void)

    init(onCloseCompletion: @escaping (() -> Void)) {
        self.onCloseCompletion = onCloseCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }
    
    @objc
    private func onSwitcherValueChange(_ switch: UISwitch) {
        self.continueButton.alpha = switcher.isOn ? 1 : 0.5
        self.continueButton.isEnabled = switcher.isOn
    }

    func setupView() {
        self.view.backgroundColor = Palette.blackColor
        self.continueButton.alpha = 0.5
        self.continueButton.isEnabled = false
        self.continueButton.addTarget(self, action:#selector(acceptOffer), for: .touchUpInside)
        self.closeButton.addTarget(self, action:#selector(close), for: .touchUpInside)
    }
    
    func addSubviews() {
        [
            self.titleLabel,
            self.separatorView,
            self.offerTermView,
            self.bottomSeparatorView,
            self.confirmationLabel,
            self.switcher,
            self.buttonsStackView
        ].forEach(self.containerView.addSubview)
        self.view.addSubview(self.containerView)
    }

    func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(23)
            make.centerX.equalToSuperview()
        }
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
        }
        self.offerTermView.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        self.bottomSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(self.offerTermView.snp.bottom).offset(20)
            make.trailing.leading.equalToSuperview()
    
        }
        self.confirmationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(self.bottomSeparatorView.snp.bottom).offset(17)
        }
        self.switcher.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(self.confirmationLabel.snp.centerY)
        }
        self.closeButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        self.continueButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        self.buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(self.confirmationLabel.snp.bottom).offset(55)
            make.leading.trailing.bottom.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(20)
        }
        self.containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(25)
        }
    }

    func presentPrivacyPolicyViewController() {
        ModalRouter(
            source: self,
            destination: WebViewController(stringURL: self.offerLink),
            modalPresentationStyle: .popover
        ).route()
    }

    @objc
    private func close() {
        self.dismiss(animated: true)
    }

    @objc
    private func acceptOffer() {
        self.dismiss(animated: true)
        self.onCloseCompletion()
    }
}
