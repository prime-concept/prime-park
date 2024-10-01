import SnapKit
import UIKit

final class CalendarDayItemView: UIView {
    private lazy var containerView = UIView()

    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.darkLightColor
        label.font = UIFont.primeParkFont(ofSize: 11)
        return label
    }()
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.darkLightColor
        label.font = UIFont.primeParkFont(ofSize: 16)
        return label
    }()
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = Palette.darkLightColor
        label.font = UIFont.primeParkFont(ofSize: 11)
        return label
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setSelectedState() {
        self.containerView.backgroundColor = Palette.mainColor
        self.containerView.layer.cornerRadius = 4
        self.bottomLabel.textColor = .white
        self.topLabel.textColor = .white
        self.mainLabel.textColor = .white
    }

    private func setWithUnselectedState() {
        self.containerView.layer.cornerRadius = 0
        self.containerView.backgroundColor = .clear
        self.bottomLabel.textColor = Palette.darkLightColor
        self.topLabel.textColor = Palette.darkLightColor
        self.mainLabel.textColor = Palette.darkLightColor
    }

    func setup(with model: DaysModel) {
        self.topLabel.text = model.date.dayOfWeek
        self.mainLabel.text = model.date.dayNumber
        self.bottomLabel.text = model.date.month
        model.isSelected ? self.setSelectedState() : self.setWithUnselectedState()
    }
}

extension CalendarDayItemView: Designable {
    func setupView() {
        self.topLabel.setContentHuggingPriority(.init(251), for: .vertical)
        self.mainLabel.setContentHuggingPriority(.init(250), for: .vertical)
        self.bottomLabel.setContentHuggingPriority(.init(252), for: .vertical)
    }

    func addSubviews() {
        self.addSubview(self.containerView)
        [
            self.topLabel,
            self.mainLabel,
            self.bottomLabel
        ].forEach(self.containerView.addSubview)
        self.containerView.layer.cornerRadius = 4
    }

    func makeConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(3)
            make.bottom.top.equalToSuperview()
        }

        self.topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(7)
            make.centerX.equalToSuperview()
        }

        self.mainLabel.snp.makeConstraints { make in
            make.top.equalTo(self.topLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        self.bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(self.mainLabel.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(7)
        }
    }
}

