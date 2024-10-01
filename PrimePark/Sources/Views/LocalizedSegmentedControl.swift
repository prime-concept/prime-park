import Foundation
import UIKit

final class LocalizedSegmentedControl: UISegmentedControl {

    @IBInspectable var localizedKeys: String? {
        didSet {
            guard let key = localizedKeys else { return }
            let localizedKeyArray = key.split(separator: ",")
            for i in 0...localizedKeyArray.count - 1 {
                setTitle(Localization.localize(String(localizedKeyArray[i])), forSegmentAt: i)
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            let maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
            layer.maskedCorners = maskedCorners
            for subview in subviews {
                subview.layer.cornerRadius = cornerRadius
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(items: [Any]?) {
        super.init(items: items)
        commonInit()
    }

    private func commonInit() {
        setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: 0x828082)], for: .normal)
        setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
    }
}
