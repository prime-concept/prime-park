import UIKit

enum CustomFontName: String {
    case regular = "Ubuntu-Regular"
    case bold = "Ubuntu-Bold"
    case italic = "Ubuntu-Italic"
    case medium = "Ubuntu-Medium"
    case light = "Ubuntu-Light"
}

// swiftlint:disable force_unwrapping
extension UIFont {
    class func primeParkFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case UIFont.Weight.ultraLight, UIFont.Weight.light, UIFont.Weight.thin:
            return UIFont(name: CustomFontName.light.rawValue, size: size)!
        case UIFont.Weight.semibold, UIFont.Weight.medium:
            return UIFont(name: CustomFontName.medium.rawValue, size: size)!
        case UIFont.Weight.bold, UIFont.Weight.heavy, UIFont.Weight.black:
            return UIFont(name: CustomFontName.bold.rawValue, size: size)!
        default:
            return UIFont(name: CustomFontName.regular.rawValue, size: size)!
        }
    }

    class func primeParkFont(ofSize size: CGFloat) -> UIFont {
        UIFont(name: CustomFontName.regular.rawValue, size: size)!
    }

    @objc
    class func boldPrimeParkFont(ofSize size: CGFloat) -> UIFont {
        UIFont(name: CustomFontName.bold.rawValue, size: size)!
    }

    @objc
    class func italicPrimeParkFont(ofSize size: CGFloat) -> UIFont {
        UIFont(name: CustomFontName.italic.rawValue, size: size)!
    }
}
// swiftlint:enable force_unwrapping
