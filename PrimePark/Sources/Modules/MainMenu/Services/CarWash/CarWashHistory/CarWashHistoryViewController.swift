import Foundation
import SnapKit

final class CarWashHistoryViewController: UIViewController {
    private var recordViewModel: HistoryRecordViewModel
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.primeParkFont(ofSize: 16)
        label.text = localizedWith("carWash.details")
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.primeParkFont(ofSize: 16)
        label.text = "Новый"
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    init(recordViewModel: HistoryRecordViewModel) {
        self.recordViewModel = recordViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.configure()
        self.setupView()
        self.makeConstraint()
    }

    func setupView() {
        self.view.backgroundColor = Palette.darkColor
        [
            self.titleLabel,
            self.separatorView,
            self.subtitleLabel,
            self.stackView
        ].forEach(self.view.addSubview)
    }

    func makeConstraint() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
        }
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView.snp.bottom).offset(27)
            make.leading.equalToSuperview().inset(15)
        }
        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }

    private func configure() {
        let timeView = HistoryInfoView()
        timeView.setup(with: localizedWith("carWash.dateAndTime.title"), subtitle: self.recordViewModel.dateAndTime)
        let keysView = HistoryInfoView()
        keysView.setup(with: localizedWith("carWash.keysHandover"), subtitle: self.recordViewModel.comment)
        let cleaningView = HistoryInfoView()
        cleaningView.setup(with: localizedWith("service.serviceType"), subtitle: self.recordViewModel.title)
        let costView = HistoryInfoView()
        costView.setup(with: localizedWith("deposit.sum.subtitle"), subtitle: "\(self.recordViewModel.cost)")
        costView.subtitleLabel.textColor = UIColor(hex: 0x36AC54)
        self.stackView.addArrangedSubviews([timeView, keysView, cleaningView, costView])
    }
}

final class HistoryInfoView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.primeParkFont(ofSize: 12)
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.primeParkFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: .zero)
        self.setupView()
        self.makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with title: String, subtitle: String) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }

    func setupView() {
        self.backgroundColor = .clear
        [
            self.titleLabel,
            self.subtitleLabel,
            self.separatorView
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview()
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview()
        }
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
