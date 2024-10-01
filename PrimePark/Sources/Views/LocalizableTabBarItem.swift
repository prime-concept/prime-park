final class LocalizableTabBarItem: UITabBarItem {
    @IBInspectable var localizedKey: String? {
        didSet {
            subscribeOnLanguageChanging()
            updateLanguage(notification: nil)
        }
    }
}

extension LocalizableTabBarItem: LanguageChangingProtocol {
    func subscribeOnLanguageChanging() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage(notification:)), name: .languageHasChanged, object: nil)
    }
    @objc
    func updateLanguage(notification: NSNotification?) {
        guard let key = localizedKey else { return }
        title = key.localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru")
    }
}
