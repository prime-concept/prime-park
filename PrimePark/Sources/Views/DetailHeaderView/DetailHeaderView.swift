import UIKit

protocol DetailHeaderViewDelegate: class {
    func onCloseButtonTap()
    func onImageTap(image: UIImage)
}

final class DetailHeaderView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 24, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: 0xf4f4f4)
        label.font = UIFont.primeParkFont(ofSize: 14)
        return label
    }()

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.blackColor
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = DetailCloseButton()
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(self.onCloseButtonTap), for: .touchUpInside)
        return button
    }()

    weak var delegate: DetailHeaderViewDelegate?

    init(delegate: DetailHeaderViewDelegate?) {
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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.bottomView.roundCorners(corners: [.topLeft, .topRight], cornerRadius: 30)
    }

    @objc
    private func onCloseButtonTap() {
        self.delegate?.onCloseButtonTap()
    }

    @objc
    private func onImageTap() {
        if let image = self.imageView.image {
            self.delegate?.onImageTap(image: image)
        }
    }
    func setup(with viewModel: News?) {
        self.titleLabel.text = viewModel?.title ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd MMMM, hh:mm"
        self.subtitleLabel.text = dateFormatter.string(from: viewModel?.createdAt ?? Date())

        if let news = viewModel,
            let url = URL(string: news.image) {
            self.imageView.loadImage(from: url)
        }
    }
}

extension DetailHeaderView: Designable {
    func setupView() {
        self.dimView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.onImageTap))
        )
    }

    func addSubviews() {
        [
            self.imageView,
            self.dimView,
            self.titleLabel,
            self.subtitleLabel,
            self.bottomView,
            self.closeButton
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.dimView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
        }

        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
        }

        self.bottomView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(20)
        }

        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
}
