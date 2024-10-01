import UIKit

protocol AuthNumberPadViewDelegate: class {
    func authNumberPad(didTap item: AuthNumberPadType)
}

final class AuthNumberPadView: UIView {
    private enum Layout {
        static let itemSpace: CGFloat = 25
        static let lineSpace: CGFloat = 20
    }

    private static var collectionViewItemSize: CGSize {
        CGSize(width: 55, height: 55)
    }

    private static var collectionViewSize: CGSize {
        CGSize(
            width: self.collectionViewItemSize.width * 3 + Layout.itemSpace * 2,
            height: self.collectionViewItemSize.height * 4 + 3 * Layout.lineSpace
        )
    }

    private lazy var numberPadCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = Self.collectionViewItemSize
        layout.minimumLineSpacing = Layout.lineSpace
        layout.minimumInteritemSpacing = Layout.itemSpace

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(cellClass: AuthNumberPadCollectionViewCell.self)

        collectionView.backgroundColor = .clear

        return collectionView
    }()

    private lazy var data: [AuthNumberPadType] = {
        var data: [AuthNumberPadType] = []
        for index in 1...9 {
            data.append(.number(index))
        }
        data.append(contentsOf: [.empty, .number(0), .delete])
        return data
    }()

    private weak var delegate: AuthNumberPadViewDelegate?

    init(delegate: AuthNumberPadViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AuthNumberPadView: Designable {
    func addSubviews() {
        self.addSubview(self.numberPadCollectionView)
    }

    func makeConstraints() {
        self.numberPadCollectionView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.size.equalTo(Self.collectionViewSize)
        }
    }
}

extension AuthNumberPadView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        self.data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let item = self.data[indexPath.row]
        let cell: AuthNumberPadCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setup(with: item)
        return cell
    }
}

extension AuthNumberPadView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.authNumberPad(didTap: self.data[indexPath.row])
    }
}
