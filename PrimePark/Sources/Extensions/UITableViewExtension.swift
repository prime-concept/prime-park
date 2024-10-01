
import UIKit
//swiftlint:disable all

extension UITableView {
    func registerNib<T: UITableViewCell>(cellClass: T.Type) {
        register(
            UINib(nibName: T.defaultReuseIdentifier, bundle: nil),
            forCellReuseIdentifier: T.defaultReuseIdentifier
        )
    }
    
    func register<T: UITableViewCell>(cellClass: T.Type) {
        register(
            cellClass,
            forCellReuseIdentifier: T.defaultReuseIdentifier
        )
    }
    
    
    func registerNib<T: UITableViewHeaderFooterView>(headerClass: T.Type) {
        register(
            UINib(nibName: T.defaultReuseIdentifier, bundle: nil),
            forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier
        )
    }
    
    func dequeueReusableCell<T: UITableViewCell>(
        for indexPath: IndexPath
    ) -> T {
        
        guard let cell = dequeueReusableCell(
            withIdentifier: T.defaultReuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }

        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        
        guard let headerFooter = dequeueReusableHeaderFooterView(
            withIdentifier: T.defaultReuseIdentifier
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }

        return headerFooter
    }
}
