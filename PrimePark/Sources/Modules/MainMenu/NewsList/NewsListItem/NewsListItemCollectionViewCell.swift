import UIKit

final class NewsListItemCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var newsListItemView = NewsListItemView()
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubviews()
        self.makeConstraints()
        isSkeletonable = true
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.contentView.addSubview(self.newsListItemView)
    }

    private func makeConstraints() {
        self.newsListItemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setup(with viewModel: News) {
        self.newsListItemView.setup(with: viewModel)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(.zero)
    }
}

extension NewsListItemCollectionViewCell {
}
