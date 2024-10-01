//
//  PanelTransition.swift
//  FluidTransition
//
//  Created by Mikhail Rubanov on 07/07/2019.
//  Copyright © 2019 akaDuality. All rights reserved.
//
// swiftlint:disable trailing_whitespace
import UIKit

enum PresentationView {
    case chooseLanguageView
    case chooseParkView
    case valetFirst
    case valetTime
    case valetTimePicker
    
    case dynamic(height: CGFloat)
}

class PanelTransition: NSObject, UIViewControllerTransitioningDelegate {
    var currentPresentation: PresentationView = .chooseParkView
    var isPresentedDismiss = true
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if source.modalPresentationStyle == .custom && isPresentedDismiss {
            source.dismiss(animated: true)
        }
        let presentationController: UIPresentationController
        switch currentPresentation {
        case .dynamic(let height):
            presentationController = DynamicPresentation(presentedViewController: presented, presenting: presenting)
            DynamicPresentation.actualHeight = height
        case .chooseParkView:
            presentationController = BlurPresentationController(presentedViewController: presented, presenting: presented)
        case .valetFirst:
            presentationController = ValetModalFirstPresentation(presentedViewController: presented, presenting: presenting)
        case .valetTime:
            presentationController = ValetModalTimePresentation(presentedViewController: presented, presenting: presenting)
        case .valetTimePicker:
            presentationController = ValetTimePickerPresententation(presentedViewController: presented, presenting: presenting)
        default:
            presentationController = SettingsPresentation(presentedViewController: presented, presenting: presenting)
        }
        return presentationController
    }
}
