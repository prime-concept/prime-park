//
//  DepositView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.06.2021.
//

import Foundation

protocol DepositViewDelegate: UITextFieldDelegate {
    func deposit(sum: String?)
}

final class DepositView: UIView {
    @IBOutlet private weak var roomLabel: UILabel!
    @IBOutlet private(set) weak var textField: LineTextField!
    @IBOutlet private weak var depositButton: LocalizableButton!
    
    weak var delegate: DepositViewDelegate?
    
    func startLoading() {
        depositButton.startButtonLoadingAnimation()
    }
    
    func stopLoading() {
        depositButton.endButtonLoadingAnimation(defaultTitle: localizedWith("charges.refill.title"))
    }
    
    func setRoom(room: String) {
        roomLabel.text = room
    }
    
    func commonInit(delegate: DepositViewDelegate) {
        self.delegate = delegate
        textField.delegate = delegate
        
        depositButton.backgroundColor = Palette.goldColor
    }
    
    func setCurrenDebt(sum: String?) {
        textField.text = sum
    }
    
    @IBAction func deposit(_ sender: Any) {
        delegate?.deposit(sum: textField.text)
    }
}
