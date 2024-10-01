import UIKit

final class AuthNumberPadCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var authNumberPadItemView = AuthNumberPadItemView(frame: .zero)

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
        self.addSubview(authNumberPadItemView)
    }

    private func makeConstraints() {
        self.authNumberPadItemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setup(with type: AuthNumberPadType) {
        self.authNumberPadItemView.setup(with: type)
    }
}
