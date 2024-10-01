//
//  UIView+SolidAnimation.swift
//  UIView+SolidAnimation
//
//  Created by Vanjo Lutik on 21.11.2021.
//

import UIKit
import ObjectiveC.runtime


private var isLoadableKey = "isLoadableKey"

extension UIView {
    var isLoadable: Bool {
        get {
            return (objc_getAssociatedObject(self, &isLoadableKey) as? Bool) ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &isLoadableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /*
            if !newValue {
                self.stopSolidAnimation()
            }
            */
        }
    }
}

extension UIView {
    
    func startSolidAnimation() {
        
        searchInView { currentView in
            
            if let tableView = currentView as? UITableView {
                
                if !tableView.isLoadable {
                    return true
                }
                
                tableView.isUserInteractionEnabled = false
                
                return false
                
            }
            
            if currentView.isLoadable {
                let view = ViewLoader(frame: UIScreen.main.bounds)
                
                currentView.addSubview(view)
                currentView.clipsToBounds = true
                
                view.makeLoadable()
                return true
            }
            return false
        }
        
    }
    
    func stopSolidAnimation(isLodable: Bool = true) {
        
        searchInView { currentView in
            
            if let tableView = currentView as? UITableView {
                
                tableView.isLoadable = isLodable
                
                tableView.isUserInteractionEnabled = true
            }
            
            if let loader = currentView as? ViewLoader {
                loader.isForceRemoving = true
                
                let loadableSuperview = loader.superview ?? UIView()
                //loadableSuperview.isLoadable = isLodable
                
                UIView.transition(
                    with: loadableSuperview,
                    duration: 0.35,
                    options: [.transitionCrossDissolve],
                    animations: {
                        loader.removeFromSuperview()
                }, completion: nil)
                
                return true
            }
            return false
        }
    }
}

fileprivate extension UIView {
    
    func searchInView(completion: @escaping (UIView) -> Bool) {
        let execute: (UIView) -> Void = { view in
            self.goThroughViews(from: view) { currentView in
                completion(currentView)
            }
        }

        if let tableView = self as? UITableView {
            
            for cell in tableView.visibleCells {
                execute(cell.contentView)
            }
        }
        
        if let tableCell = self as? UITableViewCell {
            execute(tableCell.contentView)
        } else if let collectionCell = self as? UICollectionViewCell {
            execute(collectionCell.contentView)
        } else {
            execute(self)
        }
    }
    
    @discardableResult
    func goThroughViews(from view: UIView, completion: ((UIView) -> Bool)? = nil) -> Bool {
        
        if let isTrue = completion?(view),
           isTrue {
            return true
        }
        
        for oneView in view.subviews {
            goThroughViews(from: oneView, completion: completion)
        }
        
        return false
    }
    
    @discardableResult
    func goThroughLayers(from layer: CALayer, completion: ((CALayer) -> Bool)? = nil) -> Bool {
        if let isTrue = completion?(layer),
           isTrue {
            return true
        }
        
        for oneLayer in layer.sublayers ?? [] {
            goThroughLayers(from: oneLayer, completion: completion)
        }
        
        return false
    }
    
    func removeLayerWithAnimation(from view: UIView, forKey: String) {
        goThroughViews(from: view) { [weak self] view in
            guard let strongSelf = self else { return false }
            
            return strongSelf.goThroughLayers(from: view.layer) { layer in
                if layer.animation(forKey: forKey) != nil {
                    
                    layer.removeAnimation(forKey: forKey)
                    layer.removeFromSuperlayer()
                    
                    return true
                }
                return false
            }
        }
    }
}

private final class ViewLoader: UIView, CAAnimationDelegate {
    
    let gradientLayer = CAGradientLayer()
    var isForceRemoving = false
    
    func makeLoadable() {
        gradientLayer.colors = [Palette.darkColor.cgColor, Palette.blackColor.cgColor, Palette.darkColor.cgColor]
        gradientLayer.locations = [0.4, 0.6, 1]
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.6, 0.2]
        animation.toValue = [1, 1.6, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .greatestFiniteMagnitude
        animation.delegate = self
        gradientLayer.add(animation, forKey: "LayerHolder")
        
        layer.addSublayer(gradientLayer)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let isAnimationSuccessfullFinished = flag
        
        if isAnimationSuccessfullFinished || isForceRemoving {
            //print("ANIMATION: END SUCCESSFULL")
            
            /*
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1.0
            opacityAnimation.toValue = 0.0
            opacityAnimation.duration = 1
            gradientLayer.add(opacityAnimation, forKey: "opacityAnimation")
            */
            
            gradientLayer.removeAnimation(forKey: "LayerHolder")
            gradientLayer.removeFromSuperlayer()
        } else {
            //print("ANIMATION: END FAILURE")
            if window != nil {
                gradientLayer.add(anim, forKey: "LayerHolder")
            }
        }
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        //print("ANIMATION: START")
    }
}
