import UIKit
import SkeletonView
//swiftlint:disable all
protocol NewsListViewProtocol: class, ModalRouterSourceProtocol {
    func set(data: [News])
}

final class NewsListViewController: UIViewController, CollectionSkeletonLoading {
    
    private var isNewsUpdatingDone = false
    private var contentOffset = CGPoint(x: 0, y: 0)
    
    private static let itemSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: 290
    )
    
    private lazy var statusBarView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.darkColor
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: Self.itemSize.width, height: 10)
        layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
//        layout.itemSize = Self.itemSize
//        layout.minimumLineSpacing = 0

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = Palette.blackColor

        view.dataSource = self
        view.delegate = self

        view.register(cellClass: NewsListItemCollectionViewCell.self)
        view.register(viewClass: CollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
        return view
    }()
    
    private lazy var loadingView: LoadScreen = {
        var view = Bundle.main.loadNibNamed("LoadScreen", owner: nil, options: nil)?.first as? LoadScreen ?? LoadScreen()
        return view
    }()

    private let presenter: NewsListPresenterProtocol

    private var data: [News] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            DispatchQueue.main.async {
                self.collectionView.setContentOffset(self.contentOffset, animated: false)
            }
        }
    }
    
    var isLoaded: Bool = false {
        didSet {
            triggerSkeletonLoading()
        }
    }

    init(presenter: NewsListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = Palette.blackColor

        view.addSubview(self.collectionView)

        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.leading.trailing.equalToSuperview()
        }

        self.view = view
        
        self.view.insertSubview(loadingView, at: 1)
        self.loadingView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Localization.localize("news.title")
        self.presenter.refresh(with: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(statusBarView)
        
        self.statusBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(UIApplication.shared.statusBarFrame.height)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        isLoaded = false
    }
}

extension NewsListViewController: NewsListViewProtocol {
    func set(data: [News]) {
        if data.isEmpty {
            return
        }
        self.data.append(contentsOf: data)
        UIView.animate(withDuration: 0.25) {
            self.loadingView.alpha = 0.0
        }
        isNewsUpdatingDone = true
    }
}

extension NewsListViewController: UICollectionViewDataSource {
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
        let cell: NewsListItemCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setup(with: self.data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionFooterView.defaultReuseIdentifier, for: indexPath)
            return view
        }
        return UICollectionReusableView()
    }
}

extension NewsListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottom = scrollView.contentOffset.y + scrollView.frame.height
        if bottom > scrollView.contentSize.height && isNewsUpdatingDone {
            contentOffset.y = bottom - scrollView.frame.height
            isNewsUpdatingDone = false
            presenter.refresh(with: data.count)
        }
    }
}

extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presenter.select(itemAt: indexPath.row)
    }
}

final class CollectionFooterView: UICollectionReusableView, Reusable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSpiner()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSpiner() {
        let loading = UIActivityIndicatorView(style: .white)
        loading.center = self.center
        self.addSubview(loading)
        loading.startAnimating()
    }
}
