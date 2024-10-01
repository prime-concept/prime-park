import Foundation
import SnapKit

final class CarWashServiceTableViewCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    private lazy var separatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()
    private lazy var checkmarkImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "check-mark"))
        return image
    }()
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                super.isSelected = true
                self.checkmarkImageView.isHidden = false
            } else {
                super.isSelected = false
                self.checkmarkImageView.isHidden = true
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with model: ServicesViewModel) {
        self.titleLabel.attributedText = model.title.attributed()
            .primeFont(ofSize: 16, lineHeight: 20)
            .lineBreakMode(.byTruncatingTail)
            .string()
        self.isSelected = model.isSelected
    }
    
    func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }

    func addSubviews() {
        [
            self.titleLabel,
            self.checkmarkImageView,
            self.separatorView
        ].forEach(self.contentView.addSubview)
    }

    func makeConstraints() {
        self.contentView.make(.edges, .equalToSuperview)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(13)
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().inset(50)
        }
        self.checkmarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(13)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
        }
    }
}
