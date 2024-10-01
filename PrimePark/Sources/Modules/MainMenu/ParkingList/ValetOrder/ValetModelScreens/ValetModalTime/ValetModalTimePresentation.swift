//
//  ValetModalTimePresentation.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//

import UIKit

class ValetModalTimePresentation: BlurPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            origin: CGPoint(x: 0, y: containerView.frame.height * 0.6),
            size: CGSize(width: containerView.frame.width, height: containerView.frame.height * 0.4)
            )
    }
}
