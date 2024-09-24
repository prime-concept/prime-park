//  TransitionDriver.swift
//  FluidTransition
//
//  Created by Mikhail Rubanov on 07/07/2019.
//  Copyright © 2019 akaDuality. All rights reserved.
//

import UIKit

class TransitionDriver: UIPercentDrivenInteractiveTransition {
    // MARK: - Linking
    func link(to controller: UIViewController) {
        presentedController = controller
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handle(recognizer:)))
        if let panGR = panRecognizer {
            presentedController?.view.addGestureRecognizer(panGR)
        }
    }

    private weak var presentedController: UIViewController?
    private var panRecognizer: UIPanGestureRecognizer?

    // MARK: - Override
    override var wantsInteractiveStart: Bool {
        get {
            switch direction {
            case .present:
                return false
            case .dismiss:
                let gestureIsActive = panRecognizer?.state == .began
                return gestureIsActive
            }
        }
        set {}
    }

    // MARK: - Direction
    var direction: TransitionDirection = .present

    @objc
    private func handle(recognizer: UIPanGestureRecognizer) {
        switch direction {
        case .present:
            handlePresentation(recognizer: recognizer)
        case .dismiss:
            handleDismiss(recognizer: recognizer)
        }
    }
}

// MARK: - Gesture Handling
extension TransitionDriver {
    private func handlePresentation(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            pause()
        case .changed:
            let increment = -recognizer.incrementToBottom(maxTranslation: maxTranslation)
            update(percentComplete + increment)

        case .ended, .cancelled:
            if recognizer.isProjectedToDownHalf(maxTranslation: maxTranslation) {
                cancel()
            } else {
                finish()
            }

        case .failed:
            cancel()

        default:
            break
        }
    }

    private func handleDismiss(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            pause() // Pause allows to detect isRunning

            if !isRunning {
                presentedController?.dismiss(animated: true) // Start the new one
            }

        case .changed:
            update(percentComplete + recognizer.incrementToBottom(maxTranslation: maxTranslation))

        case .ended, .cancelled:
            if recognizer.isProjectedToDownHalf(maxTranslation: maxTranslation) {
                finish()
            } else {
                cancel()
            }

        case .failed:
            cancel()

        default:
            break
        }
    }

    var maxTranslation: CGFloat {
        return presentedController?.view.frame.height ?? 0
    }

    /// `pause()` before call `isRunning`
    private var isRunning: Bool {
        return percentComplete != 0
    }
}

private extension UIPanGestureRecognizer {
    func isProjectedToDownHalf(maxTranslation: CGFloat) -> Bool {
        let endLocation = projectedLocation(decelerationRate: .fast)
        let isPresentationCompleted = endLocation.y > maxTranslation / 2
        return isPresentationCompleted
    }

    func incrementToBottom(maxTranslation: CGFloat) -> CGFloat {
        let translation = self.translation(in: view).y
        setTranslation(.zero, in: nil)
        let percentIncrement = translation / maxTranslation
        return percentIncrement
    }
}
