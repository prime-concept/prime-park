import UIKit

protocol Reusable: class {
    static var defaultReuseIdentifier: String { get }
}

extension Reusable where Self: UIView {
    static var defaultReuseIdentifier: String {
        String(describing: self)
    }
}

extension UITableViewHeaderFooterView: Reusable {}
extension UITableViewCell: Reusable {}
