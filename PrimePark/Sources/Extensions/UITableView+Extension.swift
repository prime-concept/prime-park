//
//  UITableView+Extension.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 28.02.2021.
//

import Foundation

protocol DawnDesign {
    func makeHalfDawnDesign()
    func removeDawnDesign()
}

extension DawnDesign where Self: UIScrollView {
    func makeHalfDawnDesign() {
        let tempGradient = CAGradientLayer()
        tempGradient.name = "makeHalfDawnDesign"
        tempGradient.frame.size = visibleSize
        tempGradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        tempGradient.endPoint = CGPoint(x: 0.5, y: 0.75)
        layer.mask = tempGradient
    }
    
    func removeDawnDesign() {
        layer.mask = nil
    }
}

extension UIScrollView: DawnDesign {}
