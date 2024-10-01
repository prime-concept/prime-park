import UIKit

@IBDesignable
class LayerBackgroundView: UIView {
    enum ShadowAttributes {
        static let color = UIColor(hex: 0x4A4A4A)
        static let opacity: Float = 1
        static let radius: CGFloat = 0
        static let bottomOffset = CGSize(width: 0, height: 1)
        static let topOffset = CGSize(width: 0, height: -1)
    }
    
    @IBInspectable var isBottomShadow: Bool = true {
        didSet {
            dropShadow(isBottomShadow: isBottomShadow)
        }
    }

    init(isBottomShadow: Bool = true) {
        super.init(frame: .zero)
        dropShadow(isBottomShadow: isBottomShadow)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        dropShadow(isBottomShadow: isBottomShadow)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        dropShadow(isBottomShadow: isBottomShadow)
    }

    private func dropShadow(isBottomShadow: Bool) {
        self.layer.shadowColor = ShadowAttributes.color.cgColor
        self.layer.shadowOpacity = ShadowAttributes.opacity
        self.layer.shadowOffset = isBottomShadow ? ShadowAttributes.bottomOffset : ShadowAttributes.topOffset
        self.layer.shadowRadius = ShadowAttributes.radius
        //self.layer.masksToBounds = false
    }
}

extension UIView {
    func addTopBorder(color: UIColor, height: CGFloat) {
        let path = UIBezierPath()
        path.move(to: .init(x: 0, y: 15))
        path.addArc(
            withCenter: CGPoint(x: 15, y: 15),
            radius: 15,
            startAngle: .pi,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        path.addLine(to: .init(x: bounds.width - 15, y: 0))
        path.addArc(
            withCenter: CGPoint(x: bounds.width - 15, y: 15),
            radius: 15,
            startAngle: 3 * .pi / 2,
            endAngle: 0,
            clockwise: true
        )
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = LayerBackgroundView.ShadowAttributes.color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
        self.layer.addSublayer(shapeLayer)
    }
}
