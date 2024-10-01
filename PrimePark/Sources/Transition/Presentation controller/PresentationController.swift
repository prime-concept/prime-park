//
//  PresentationController.swift
//  FluidTransition
//
//  Created by Mikhail Rubanov on 29/06/2019.
//  Copyright © 2019 akaDuality. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {

    override var shouldPresentInFullscreen: Bool {
        return false
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = containerView?.bounds ?? CGRect()
        let height = bounds.height * 2 / 3
        return CGRect(
            x: 0,
            y: bounds.height - height + 50,
            width: bounds.width,
            height: height - 50
        )
    }

    override func presentationTransitionWillBegin() {
        containerView?.addSubview(presentedView ?? UIView())
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    var driver: TransitionDriver?

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if completed {
            driver?.direction = .dismiss
        }
    }
}
