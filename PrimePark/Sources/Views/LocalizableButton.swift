import Foundation
import UIKit

final class LocalizableButton: UIButton {
    var additionText: String = "" {
        didSet {
            updateLanguage(notification: nil)
        }
    }

    @IBInspectable var localizedKey: String? {
        didSet {
            subscribeOnLanguageChanging()
            updateLanguage(notification: nil)
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            guard let color = borderColor else { return }
            layer.borderColor = color.cgColor
            layer.borderWidth = 1
        }
    }
}

extension LocalizableButton: LanguageChangingProtocol {
    func subscribeOnLanguageChanging() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLanguage(notification:)),
            name: .languageHasChanged,
            object: nil
        )
    }
    @objc
    func updateLanguage(notification: NSNotification?) {
        guard let key = localizedKey else { return }
        setTitle(key.localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru") + additionText, for: .normal)
    }
}
