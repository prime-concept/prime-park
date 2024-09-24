import UIKit

protocol Designable: class {
    /// Setup view parameters (e.g. set colors, fonts, etc)
    func setupView()
    /// Set up subviews hierarchy
    func addSubviews()
    /// Add constraints
    func makeConstraints()
}

extension Designable where Self: UIView {
    func setupView() {
        // Empty body to make method optional
    }

    func addSubviews() {
        // Empty body to make method op@objc tional
    }

    func makeConstraints() {
        // Empty body to make method optional
    }
}
