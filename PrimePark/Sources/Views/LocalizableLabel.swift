import UIKit

@IBDesignable
final class LocalizableLabel: UILabel {
    @IBInspectable var localizedKey: String? {
        didSet {
            subscribeOnLanguageChanging()
            updateLanguage(notification: nil)
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.masksToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
}

extension LocalizableLabel: LanguageChangingProtocol {
    func subscribeOnLanguageChanging() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage(notification:)), name: .languageHasChanged, object: nil)
    }
    @objc
    func updateLanguage(notification: NSNotification?) {
        guard let key = localizedKey else { return }
        text = key.localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru")
    }
}
