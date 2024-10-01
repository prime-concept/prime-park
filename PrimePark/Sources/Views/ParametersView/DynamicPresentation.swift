//
//  ParametersPresentation.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 31.05.2021.
//
// swiftlint:disable trailing_whitespace
import UIKit

class DynamicPresentation: BlurPresentationController {
    private static let halfScreen = UIScreen.main.bounds.height / 2
    
    static var actualHeight = halfScreen {
        didSet {
            if actualHeight > halfScreen {
                actualHeight = halfScreen
            }
        }
    }
    
    private static var actualOriginY: CGFloat {
        return abs(UIScreen.main.bounds.height - actualHeight)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            origin: CGPoint(x: 0, y: Self.actualOriginY),
            size: CGSize(width: containerView.frame.width, height: Self.actualHeight)
            )
    }
}
