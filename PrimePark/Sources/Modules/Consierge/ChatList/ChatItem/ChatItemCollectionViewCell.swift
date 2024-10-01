import UIKit

final class ChatItemCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var chatItemView = ChatItemView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.contentView.addSubview(self.chatItemView)
    }

    private func makeConstraints() {
        self.chatItemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setup(with viewModel: ChatItemViewModel) {
        self.chatItemView.setup(with: viewModel)
    }
}
