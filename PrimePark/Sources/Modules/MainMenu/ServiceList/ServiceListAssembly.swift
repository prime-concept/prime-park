
final class ServiceListAssembly: Assembly {
    func make() -> UIViewController {
        let layout = UICollectionViewFlowLayout()
        return ServiceListCollection(collectionViewLayout: layout)
    }
}
