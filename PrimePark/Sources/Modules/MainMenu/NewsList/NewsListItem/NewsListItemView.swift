import UIKit
//swiftlint:disable all
final class NewsListItemView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(hex: 0xF4F4F4)
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.darkLightColor
        label.font = UIFont.primeParkFont(ofSize: 12)
        label.numberOfLines = 3
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.darkLightColor
        label.font = UIFont.primeParkFont(ofSize: 12)
        return label
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
}

extension NewsListItemView: Designable {
    func setupView() {
        self.subtitleLabel.setContentHuggingPriority(.init(rawValue: 252), for: .vertical)
        self.titleLabel.setContentHuggingPriority(.init(rawValue: 251), for: .vertical)
        self.dateLabel.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
    }

    func addSubviews() {
        [
            self.imageView,
            self.dimView,
            self.titleLabel,
            self.subtitleLabel,
            self.dateLabel
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.height.equalTo(150)
            make.top.leading.trailing.equalToSuperview().inset(15)
        }

        self.dimView.snp.makeConstraints { make in
            make.edges.equalTo(self.imageView)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(15)
        }

        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(15)
        }

        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-1)
        }
    }

    func setup(with viewModel: News) {
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.dateLabel.text = dateFormatter.string(from: viewModel.createdAt)

        if let url = URL(string: viewModel.image) {
            self.imageView.loadImage(from: url)
        }
    }
}
