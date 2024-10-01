import UIKit

final class DetailCloseButton: UIButton {
    private var blurEffectView: UIVisualEffectView?

    init() {
        super.init(frame: .zero)

        self.clipsToBounds = true
        self.setTitleColor(.white, for: .normal)
        self.setImage(UIImage(named: "close_icon"), for: .normal)

        self.initGradient()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.blurEffectView?.frame = self.bounds
    }

    private func initGradient() {
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = false

        if let imageView = self.imageView {
            self.insertSubview(blurEffectView, belowSubview: imageView)
        } else {
            self.insertSubview(blurEffectView, at: 0)
        }

        self.blurEffectView = blurEffectView
    }
}
