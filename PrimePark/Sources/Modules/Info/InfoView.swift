import UIKit
//swiftlint:disable all
protocol InfoViewDelegate: class {
    func onBackButtonTap()
}

final class InfoView: UIView {
    weak var delegate: InfoViewDelegate?
    private var title: String
    private var subtitle: String?

    private let titleColor = UIColor.white
    private let subtitleColor = UIColor.white.withAlphaComponent(0.5)

    init(delegate: InfoViewDelegate?, title: String, subtitle: String?) {
        self.delegate = delegate
        self.title = title
        self.subtitle = subtitle
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
//        self.makeConstraints()
        self.makeAnchorConstraints()
    }

    required init?(coder: NSCoder) {
        self.delegate = nil
        self.title = ""
        self.subtitle = ""
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onBackButtonTap() {
        self.delegate?.onBackButtonTap()
    }

    public func addText(title: String, subtitle: String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }

    private lazy var roundedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x383738)
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 17)
        label.textColor = self.titleColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = self.title
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 14)
        label.textColor = self.subtitleColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = self.subtitle
        return label
    }()

    private lazy var divideView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(hex: 0x545458).withAlphaComponent(0.65)
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(Localization.localize("error.button.ok"), for: .normal)
        button.titleLabel?.font = UIFont.primeParkFont(ofSize: 17)

        button.backgroundColor = UIColor.clear
        button.setTitleColor(Palette.goldColor, for: .normal)

        button.addTarget(self, action: #selector(self.onBackButtonTap), for: .touchUpInside)

        return button
    }()
}

extension InfoView: Designable {
    func setupView() {
        self.backgroundColor = Palette.blackColor
        //self.alpha = 0.85
        self.subtitleLabel.setContentHuggingPriority(.init(rawValue: 252), for: .vertical)
        self.titleLabel.setContentHuggingPriority(.init(rawValue: 251), for: .vertical)
    }

    func addSubviews() {
        self.addSubview(self.roundedView)
        [
            self.titleLabel,
            self.subtitleLabel,
            self.divideView,
            self.backButton
        ].forEach(self.roundedView.addSubview)
    }
    
    func makeAnchorConstraints() {
        self.roundedView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.divideView.translatesAutoresizingMaskIntoConstraints = false
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roundedView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            roundedView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            roundedView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
//            roundedView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: roundedView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -16),
            
            divideView.heightAnchor.constraint(equalToConstant: 1),
            divideView.widthAnchor.constraint(equalTo: roundedView.widthAnchor),
            divideView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            divideView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: 0),
            
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.widthAnchor.constraint(equalTo: roundedView.widthAnchor),
            backButton.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor)
        ])
    }

    /*
    func makeConstraints() {
        self.roundedView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(280)
            make.width.equalTo(UIScreen.main.bounds.width * 0.7)
            make.centerX.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        self.divideView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.bottom.equalTo(self.backButton.snp.top).offset(1)
        }

        self.backButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }
    }
 */
}
