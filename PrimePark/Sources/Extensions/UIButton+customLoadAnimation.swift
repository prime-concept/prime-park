extension UIButton {
    func startButtonLoadingAnimation(loadingTitle: String = "Пожалуйста подождите") {
        isUserInteractionEnabled = false
        setTitle(loadingTitle, for: .normal)
        guard let buttonLabel = self.titleLabel else { return }
        //Label gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.red.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        buttonLabel.layer.mask = gradientLayer
        let animation = CABasicAnimation(keyPath: "locations")
		animation.fromValue = [-1.0, -0.5, 0.0, 0.5]
		animation.toValue = [0.5, 1, 1.5, 2.0]
		animation.duration = 1.5
        animation.repeatCount = .greatestFiniteMagnitude
        gradientLayer.add(animation, forKey: nil)
    }
    
    func endButtonLoadingAnimation(defaultTitle: String = "Default title") {
        isUserInteractionEnabled = true
        guard let buttonLabel = self.titleLabel else { return }
        buttonLabel.layer.mask = nil
        setTitle(defaultTitle, for: .normal)
    }
}

extension UIView {
    func startViewLoadingAnimation() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0, 1.5, 2]
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 2, y: 1)
        layer.mask = gradientLayer
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0, 0.5]
        animation.toValue = [0.5, 1, 1.5, 2.0]
        animation.duration = 1
        animation.repeatCount = .greatestFiniteMagnitude
        gradientLayer.add(animation, forKey: nil)
    }
    func endViewLoadingAnimation() {
        layer.mask = nil
        isUserInteractionEnabled = true
    }
}
