import UIKit

protocol Accessable {
//    func changeAccess(_ role: Role)
}

protocol HomeViewDelegate: class {
    func didTap(item: HomeItemType)
}

class HomeView: UIView, Designable, Accessable {
    private enum Layout {
        static let itemSpacing: CGFloat = 6
        static let sideInset: CGFloat = 15
    }

    lazy var totalHeight: CGFloat = {
        return CGFloat(ceil(Double(data.count) / 4.0))
    }()
    
    private lazy var backgroundView = PrimeParkBackgroundView()

    lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = homeItemSize
        collectionViewLayout.minimumLineSpacing = 6
        collectionViewLayout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )

        collectionView.backgroundColor = .clear

        collectionView.register(cellClass: HomeItemCollectionViewCell.self)

        collectionView.dataSource = self
        collectionView.delegate = self

        return collectionView
    }()

    lazy var data: [HomeItemType] = changeAccess(LocalAuthService.shared.apartment?.getRole ?? .resident) {
        didSet {
            collectionView.reloadData()
        }
    }

    var homeItemSize: CGSize {
        let totalSpacing = 3 * Layout.itemSpacing
        let totalInset = 2 * Layout.sideInset
        let value = (UIScreen.main.bounds.width - totalSpacing - totalInset) / 4
        return CGSize(width: value, height: value)
    }

    lazy var collectionViewHeight: CGFloat = {
        print(totalHeight)
        return homeItemSize.height * CGFloat(totalHeight) + 6 * 2
    }()

    private weak var delegate: HomeViewDelegate?

    init(delegate: HomeViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.addSubviews()
        self.makeConstraints()
        changeAccess(LocalAuthService.shared.apartment?.getRole ?? .resident)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func addSubviews() {
        [self.backgroundView, self.collectionView].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(25)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(collectionViewHeight)
        }
    }
    
    @discardableResult
    func changeAccess(_ role: Role) -> [HomeItemType] {
        switch role {
        case .resident:
            data = [.security, .pass, .parking, .charges, .carwash, .cleaning, .drycleaning, .services, .help, .news, .restaurants, .market]
            return data
        case .cohabitant:
            data = [.security, .pass, .parking, .carwash, .cleaning, .drycleaning, .services, .help, .news, .restaurants, .market]
            return data
        case .brigadier:
            data = [.security, .pass, .parking, .help, .news]
            return data
        case .guest:
            data = [.security, .help]
            return data
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeView: UICollectionViewDataSource, UICollectionViewDelegate {
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
        let cell: HomeItemCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.homeItemView.endViewLoadingAnimation()
        cell.isUserInteractionEnabled = true
        cell.setup(with: self.data[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if data[indexPath.row] == .help {
            guard let cell = collectionView.cellForItem(at: indexPath) as? HomeItemCollectionViewCell else { return }
            cell.isUserInteractionEnabled = false
            cell.homeItemView.startViewLoadingAnimation()
        }
//        }
        self.delegate?.didTap(item: self.data[indexPath.row])
    }
}
