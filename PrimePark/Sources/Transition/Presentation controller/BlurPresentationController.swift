//
//  BlurPresentationController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 17.01.2021.
//

import CoreImage.CIFilterBuiltins
import DynamicBlurView

class BlurPresentationController: UIPresentationController {
    
    private var dynamicBlurView = DynamicBlurView()
    private var tappable = UIView()

    var tapGestureRecognizer = UITapGestureRecognizer()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        dynamicBlurView.blurRadius = 25
        dynamicBlurView.trackingMode = .tracking
        dynamicBlurView.blurRatio = 0.5
        dynamicBlurView.isDeepRendering = true
        dynamicBlurView.blendColor = .clear
        dynamicBlurView.blendMode = .hardLight
        dynamicBlurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        dynamicBlurView.isUserInteractionEnabled = true
        dynamicBlurView.addGestureRecognizer(tapGestureRecognizer)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            origin: CGPoint(x: 0, y: containerView.frame.height * 0.4),
            size: CGSize(width: containerView.frame.width, height: containerView.frame.height * 0.6)
        )
    }

    override func presentationTransitionWillBegin() {
        self.containerView?.addSubview(dynamicBlurView)
        
        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.dynamicBlurView.animate()
            }
        )
    }

    override func dismissalTransitionWillBegin() {
      self.presentedViewController.transitionCoordinator?.animate(
        alongsideTransition: { _ in
            self.dynamicBlurView.alpha = 0
        }, completion: { _ in
            self.dynamicBlurView.removeFromSuperview()
      })
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.roundCorners([.topLeft, .topRight], radius: 22)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        dynamicBlurView.frame = containerView?.bounds ?? .zero
    }

    @objc
    func dismissController() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

    extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(
                              roundedRect: bounds,
                              byRoundingCorners: corners,
                              cornerRadii: CGSize(width: radius, height: radius)
                             )
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      layer.mask = mask
    }
}


/*
extension UIView {
    var toImage: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in layer.render(in: rendererContext.cgContext) }
    }
    
    func makeBlurView() -> UIView? {
        let initialImg = toImage
        guard
            let bluredImg = initialImg.makeCircularBlur(rect: bounds)
            //let resize = bluredImg.resizeToBoundingSquare(bounds.height)
        else { return nil }
        let view = bluredImg.toView()
        return view
    }
}

extension UIImage {
    func toView() -> UIView {
        let imgView = UIImageView(image: self)
        imgView.image = self
        imgView.contentMode = .scaleAspectFit
        return imgView
    }
    
    func makeCircularBlur(rect: CGRect) -> UIImage? {
        guard let ciImage = CIImage(image: self)?.clampedToExtent() else { return nil }
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(10, forKey: kCIInputRadiusKey)
        guard let outputImage = blurFilter?.outputImage?.cropped(to: rect) else { return nil }
        return UIImage(ciImage: outputImage)
    }
    
    public func resizeToBoundingSquare(_ boundingSquareSideLength: CGFloat) -> UIImage? {
        let imgScale = self.size.width > self.size.height ? boundingSquareSideLength / self.size.width : boundingSquareSideLength / self.size.height
        let newWidth = self.size.width * imgScale
        let newHeight = self.size.height * imgScale
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
*/
