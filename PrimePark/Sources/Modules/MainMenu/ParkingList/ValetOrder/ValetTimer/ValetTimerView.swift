//
//  ValetTimerView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.05.2021.
//

import Foundation

protocol ValetTimerViewDelegate: AnyObject {
    func back()
    func stopServe()
    func changeTime()
}

final class ValetTimerView: UIView {
    
    @IBOutlet weak var timerProgressBar: ProgressTimeBar!
    
    weak var delegate: ValetTimerViewDelegate?
    var isForcedToRemove: Bool = false {
        didSet {
            timerProgressBar.isForcedToRemove = isForcedToRemove
        }
    }
    
    func commonInit(delegate: ValetTimerViewDelegate, duration: Int, fromValue: Float, isForcedToRemove: Bool) {
        self.delegate = delegate
        self.isForcedToRemove = isForcedToRemove
        timerProgressBar.isForcedToRemove = isForcedToRemove
        timerProgressBar.setProgressWithAnimation(duration: Double(duration), fromValue: fromValue)
    }
    
    @IBAction func back(_ sender: Any) {
        delegate?.back()
    }
    
    @IBAction func stopServe(_ sender: Any) {
        delegate?.stopServe()
    }
    
    func stopProgressBar() {
        timerProgressBar.stopProgressBar()
    }
    
    @IBAction func changeTime(_ sender: Any) {
        delegate?.changeTime()
    }
    
    func startAnimation(duration: Double, toValue: Float) {
        timerProgressBar.setProgressWithAnimation(duration: duration, toValue: toValue)
    }
}
