//
//  ValetTimePickerPresententation.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 06.05.2021.
//

import Foundation

class ValetTimePickerPresententation: BlurPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            origin: CGPoint(x: 0, y: containerView.frame.height * 0.6),
            size: CGSize(width: containerView.frame.width, height: containerView.frame.height * 0.4)
            )
    }
}
