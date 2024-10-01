import UIKit

final class ChatItemView: UIView {
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)
        label.textColor = Palette.darkLightColor
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 14)
        label.textColor = Palette.darkLightColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 11)
        label.textColor = Palette.darkLightColor
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 11)
        label.textColor = Palette.darkLightColor
        return label
    }()

    private lazy var unreadMessageCountLabel: UILabel = {
        let label = PaddingLabel()
        label.textAlignment = .center
        label.font = UIFont.primeParkFont(ofSize: 12, weight: .medium)

        label.setContentHuggingPriority(.init(249), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(752), for: .horizontal)

        label.textColor = Palette.darkColor
        label.backgroundColor = Palette.goldColor

        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.darkLightColor.withAlphaComponent(0.2)
        return view
    }()

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

    func setup(with viewModel: ChatItemViewModel) {
        self.idLabel.text = viewModel.id
        self.nameLabel.text = viewModel.name
        self.messageLabel.text = viewModel.message
        self.phoneLabel.text = viewModel.phone
        self.dateLabel.text = viewModel.date
        self.unreadMessageCountLabel.isHidden = viewModel.unreadMessageCount == nil

        if let count = viewModel.unreadMessageCount {
            self.unreadMessageCountLabel.text = "+\(count)"
        }

        self.backgroundColor = viewModel.unreadMessageCount == nil
            ? UIColor(hex: 0x202020)
            : .black
    }
}

extension ChatItemView: Designable {
    func setupView() {
        self.backgroundColor = UIColor(hex: 0x202020)
    }

    func addSubviews() {
        [
            self.idLabel,
            self.nameLabel,
            self.messageLabel,
            self.phoneLabel,
            self.dateLabel,
            self.unreadMessageCountLabel,
            self.separatorView
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.idLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(15)
        }

        self.nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(self.idLabel.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualTo(self.unreadMessageCountLabel.snp.leading).offset(-5)
        }

        self.messageLabel.snp.makeConstraints { make in
            make.top.equalTo(self.idLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(self.unreadMessageCountLabel.snp.leading).offset(-16)
        }

        self.phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(self.messageLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
        }

        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.messageLabel.snp.bottom).offset(10)
            make.trailing.equalToSuperview().inset(15)
        }

        self.unreadMessageCountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-15)
        }

        self.separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
}
