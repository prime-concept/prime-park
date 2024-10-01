import Foundation
import UIKit

final class TextFieldWithCustomPlaceholder: UITextField {
    private var placeHolderColor: UIColor?

    @IBInspectable var localizedKey: String? {
        didSet {
            guard let key = localizedKey else { return }
            text = Localization.localize(key)
        }
    }

    // swiftlint:disable force_unwrapping
    @IBInspectable var localizedPlaceholderKey: String? {
        didSet {
            guard let key = localizedPlaceholderKey else { return }
            placeholder = Localization.localize(key)
            self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: placeHolderColor ?? self.tintColor!])
        }
    }

    @IBInspectable var placeholderColor: UIColor? {
        didSet {
            guard let color = placeholderColor else { return }
            self.placeHolderColor = color
            self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: placeHolderColor ?? self.tintColor!])
        }
    }
}
