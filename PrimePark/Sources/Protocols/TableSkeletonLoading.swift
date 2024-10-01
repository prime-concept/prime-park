//swiftlint:disable all

protocol Loadable {
    func triggerLoading()
}

protocol LoadableWithButton: Loadable {
    var requestButton: LocalizableButton! { get }
}

extension Loadable where Self: UIViewController {
    func triggerLoading() {
        if var loadableView = view as? SkeletonLoading {
            loadableView.isLoaded = false
        }
    }
}

protocol SkeletonLoading {
    var isLoaded: Bool { get set }
    
    func triggerSkeletonLoading()
}

protocol TableSkeletonLoading: class, SkeletonLoading {
    var tableView: UITableView! { get set }
}

protocol CollectionSkeletonLoading: class, SkeletonLoading {
    var collectionView: UICollectionView { get set }
}

extension TableSkeletonLoading {
    func triggerSkeletonLoading() {
        isLoaded ? tableView.removeDawnDesign() : tableView.makeHalfDawnDesign()
        tableView.isUserInteractionEnabled = isLoaded
        tableView.reloadData()
    }
}

extension CollectionSkeletonLoading {
    func triggerSkeletonLoading() {
        isLoaded ? collectionView.removeDawnDesign() : collectionView.makeHalfDawnDesign()
        collectionView.isUserInteractionEnabled = isLoaded
        collectionView.reloadData()
    }
}
