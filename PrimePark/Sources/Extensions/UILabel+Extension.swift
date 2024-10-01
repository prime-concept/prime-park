import UIKit

extension UILabel {
	func dropTextShadow(
		color: UIColor = .black,
		radius: CGFloat = 5.0,
		opacity: Float = 1,
		offset: CGSize = .zero
	) {
		self.layer.shadowColor = color.cgColor
		self.layer.shadowRadius = radius
		self.layer.shadowOpacity = opacity
		self.layer.shadowOffset = offset
		self.layer.masksToBounds = false
	}
}
