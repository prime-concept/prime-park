//
//  ProgressTimeBar.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.05.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation

final class ProgressTimeBar: UIView {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    var isForcedToRemove = false
    
    var currentProgressValue: Float? {
        return progressLayer.presentation()?.value(forKey: "strokeEnd") as? Float
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    
    var progressColor = UIColor(hex: 0xB3987A) {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor(hex: 0x323232) {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    fileprivate func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width / 2
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2),
            radius: (frame.size.width - 1.5) / 2,
            startAngle: CGFloat(-0.5 * .pi),
            endAngle: CGFloat(1.5 * .pi),
            clockwise: true
        )
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, fromValue: Float = 0.0, toValue: Float = 1.0) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(toValue)
        progressLayer.add(animation, forKey: "animateprogress")
    }
    
    deinit {
        layer.removeAllAnimations()
    }
}

extension ProgressTimeBar: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        print("animationDidStart")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let isAnimationSuccessfulFinished = flag
        
        if window != nil { // check if this view is current presented
            
            if !isAnimationSuccessfulFinished && !isForcedToRemove {
                
                if progressLayer.animation(forKey: "animateprogress") == nil {
                    print("animationDidStop progressLayer.add")
                    progressLayer.add(anim, forKey: "animateprogress")
                }
                
            } else if isForcedToRemove {
                print("animationDidStop true")
                progressLayer.removeAnimation(forKey: "animateprogress")
            }
            
        }
    }
}

extension ProgressTimeBar {
    func stopProgressBar() {
        let duration = TimeInterval(1 * (currentProgressValue ?? 0.0))
        setProgressWithAnimation(duration: duration, fromValue: currentProgressValue ?? 0.0, toValue: 0)
    }
}
