//
//  LoadScreen.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 28.02.2021.
//
//swiftlint:disable all
import UIKit

class LoadScreen: UIView {
    
    @IBOutlet var arr: [RoundedView]!
    
    override func awakeFromNib() {
        self.backgroundColor = Palette.blackColor
        super.awakeFromNib()
        arr.forEach { $0.showAnimatedGradientSkeleton() }
    }
}
