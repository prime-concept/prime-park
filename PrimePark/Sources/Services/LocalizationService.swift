import Foundation

//swiftlint:disable nslocalizedstring_key
enum Localization {
    static func localize(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}

extension String {
	var localized: String {
		return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
	}
	
    func localized(_ language: String) -> String {
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        guard let clearPath = path else { return "path nil" }
        let bundle = Bundle(path: clearPath)
        guard let clearBundle = bundle else { return "bundle nil" }
        return NSLocalizedString(self, tableName: nil, bundle: clearBundle, value: "", comment: "")
    }
}

func localizedWith(_ path: String) -> String {
    return path.localized(LocalAuthService.shared.choosenLanguage?.description ?? "ru")
}
