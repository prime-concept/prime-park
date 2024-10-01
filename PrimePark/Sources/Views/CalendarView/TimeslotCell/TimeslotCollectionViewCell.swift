import Foundation
import UIKit

final class TimeslotCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.primeParkFont(ofSize: 12)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with timeslot: TimeslotModel) {
        self.timeLabel.text = timeslot.timeslot.time
        timeslot.isSelected ? setSelectedState() : setUnselectedState()
    }
    
    private func setSelectedState() {
        self.contentView.backgroundColor = Palette.mainColor
        self.contentView.layer.borderWidth = 0
    }
    
    private func setUnselectedState() {
        self.contentView.backgroundColor = .clear
        self.contentView.layer.borderWidth = 1
    }
}

extension TimeslotCollectionViewCell: Designable {
    func setupView() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor(hex: 0x606060).withAlphaComponent(0.4).cgColor
    }

    func addSubviews() {
        self.contentView.addSubview(self.timeLabel)
    }

    func makeConstraints() {
        self.timeLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
        }
    }
}
