//  OverlayViewController.swift
//  PrimePark
//
//  Created by IvanLyuhtikov on 24.12.20.
//

import UIKit

class PannableViewController: UIViewController {
    var additionalCardHeightConstraint: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc
    func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        //print(translation)
        let cardPositionY = UIScreen.main.bounds.maxY - self.view.bounds.maxY
        let cardMiddlePositionY = cardPositionY + self.view.bounds.maxY / 2
        guard translation.y >= 0 else { return }
        self.view.frame.origin.y = translation.y + cardPositionY - additionalCardHeightConstraint
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 || self.view.frame.origin.y > cardMiddlePositionY {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
                    self.view.frame.origin = CGPoint(x: 0, y: cardPositionY - self.additionalCardHeightConstraint)
                }
            }
        }
    }
}
