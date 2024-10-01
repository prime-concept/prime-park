import UIKit

final class HomeItemCollectionViewCell: UICollectionViewCell, Reusable {
    lazy var homeItemView = HomeItemView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = Palette.darkColor.withAlphaComponent(0.8)
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.contentView.addSubview(self.homeItemView)
    }

    private func makeConstraints() {
        self.homeItemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setup(with type: HomeItemType) {
        self.homeItemView.setup(with: type)
    }
}
