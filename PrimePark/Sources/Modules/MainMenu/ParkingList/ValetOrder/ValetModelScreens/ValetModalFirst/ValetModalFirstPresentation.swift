//
//  ValetModalFirstPresentation.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 04.05.2021.
//

import UIKit

class ValetModalFirstPresentation: BlurPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            origin: CGPoint(x: 0, y: containerView.frame.height * 0.7),
            size: CGSize(width: containerView.frame.width, height: containerView.frame.height * 0.3)
            )
    }
}
