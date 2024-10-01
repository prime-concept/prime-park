import Foundation
import SnapKit

final class CarWashHistorTableViewCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.text = localizedWith("carWash.title")
        return label
    }()
    private lazy var priceLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 12, weight: .semibold)
        label.textColor = .green
        return label
    }()
    private lazy var statusLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 11, weight: .semibold)
        label.textColor = .gray
        label.text = " "
        return label
    }()
    private lazy var timeLabel: UILabel  = {
        var label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 11, weight: .regular)
        label.textColor = .gray
        return label
    }()
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "car_wash_history"))
        return imageView
    }()
    private lazy var separatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()
    private lazy var descriptionLabel: UILabel  = {
        var label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
    private lazy var backgroundContentView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with model: HistoryRecordViewModel) {
        self.priceLabel.text = "\(model.cost)"
        self.descriptionLabel.text = model.title
        self.timeLabel.text = model.date
    }
    
    func setupView() {
        self.backgroundContentView.backgroundColor = Palette.backgroundCell
        self.backgroundContentView.layer.cornerRadius = 10
        self.selectionStyle = .none
        self.iconImageView.layer.cornerRadius = 18
        self.contentView.backgroundColor = Palette.blackColor
    }

    func addSubviews() {
        [
            self.iconImageView,
            self.titleLabel,
            self.priceLabel,
            self.statusLabel,
            self.timeLabel,
            self.separatorView,
            self.descriptionLabel
        ].forEach(self.backgroundContentView.addSubview)
        self.contentView.addSubview(self.backgroundContentView)
    }

    func makeConstraints() {
        self.iconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 36, height: 36))
            make.leading.top.equalToSuperview().inset(10)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(10)
        }
        self.priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(10)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
        }
        self.statusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
        self.timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(self.priceLabel.snp.centerY)
        }
        self.separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(self.iconImageView.snp.bottom).offset(10)
        }
        self.descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(self.separatorView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(15)
        }
        self.backgroundContentView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
    }
}
