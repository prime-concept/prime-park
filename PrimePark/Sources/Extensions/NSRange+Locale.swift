import Foundation

enum TermsRange {
    static var termsRange: NSRange {
        switch Locale.current.languageCode {
        case "ru":
            return NSRange(location: 48, length: 35)
        default:
            return NSRange(location: 46, length: 37)
        }
    }

    static var offerRange: NSRange {
        switch Locale.current.languageCode {
        case "ru":
            return NSRange(location: 100, length: 22)
        default:
            return NSRange(location: 105, length: 20)
        }
    }
}
