import UIKit

final class CalendarDayItemCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var itemView = CalendarDayItemView()
    
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

    func setup(with date: DaysModel) {
        self.itemView.setup(with: date)
    }
}

extension CalendarDayItemCollectionViewCell: Designable {
    func setupView() {
        self.contentView.clipsToBounds = false
    }

    func addSubviews() {
        self.contentView.addSubview(self.itemView)
    }

    func makeConstraints() {
        self.itemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
