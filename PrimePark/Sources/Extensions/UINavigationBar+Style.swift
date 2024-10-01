import UIKit

extension UINavigationBar {
    func applyStyle() {
        self.isTranslucent = true
        self.backgroundColor = Palette.darkColor
        self.barTintColor = Palette.darkColor
        self.tintColor = Palette.goldColor
        self.titleTextAttributes = [
            .font: UIFont.primeParkFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.white
        ]

        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()

        let barButtonAppearance = UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [UINavigationBar.self]
        )
        barButtonAppearance.setTitleTextAttributes(
            [.font: UIFont.primeParkFont(ofSize: 16, weight: .medium)],
            for: .normal
        )
        barButtonAppearance.setTitleTextAttributes(
            [.font: UIFont.primeParkFont(ofSize: 16, weight: .medium)],
            for: .highlighted
        )
    }

    func applyAuthStyle() {
        self.isTranslucent = false
        self.backgroundColor = UIColor(hex: 0x252525)
        self.barTintColor = UIColor(hex: 0x252525)
        self.tintColor = Palette.goldColor

        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
    }
}
