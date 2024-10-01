//
//  ValetOrderView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.05.2021.
//
//swiftlint:disable all
import UIKit

protocol ValetOrderViewDelegate: UITextFieldDelegate {
    func back()
    func tapSearchButton(ticket: String?, pin: String?)
    func tapLaterButton()
}

class ValetOrderView: UIView {
    @IBOutlet weak var ticketTextField: LineTextField!
    @IBOutlet weak var pinTextField: LineTextField!
    
    @IBOutlet weak var searchButton: LocalizableButton!
    @IBOutlet weak var searchButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var laterButton: LocalizableButton!
    @IBOutlet weak var laterButtonTopConstraint: NSLayoutConstraint!
    
    weak var delegate: ValetOrderViewDelegate?
	
    private var parkingTicket: ParkingTicket? {
        didSet {
            ticketTextField.text = parkingTicket?.visualFormat.ticket
            pinTextField.text = parkingTicket?.visualFormat.pin
        }
    }
	var isFound = false
    
    func commonInit(ticket: ParkingTicket) {
        parkingTicket = ticket
        
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 14)
        label.textColor = UIColor(hex: 0x828082)
        label.text = ticket.ticketPrefix + " "
        ticketTextField.setLeftLabel(label: label)
        
        ticketTextField.delegate = delegate
        ticketTextField.keyboardType = .numberPad
        
        pinTextField.delegate = delegate
        pinTextField.keyboardType = .numberPad
        
        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
        laterButton.addTarget(self, action: #selector(didTapLaterButton), for: .touchUpInside)
    }
    
    @objc
    func didTapSearchButton() {
        delegate?.tapSearchButton(ticket: ticketTextField.text, pin: pinTextField.text)
		!isFound ? searchButton.startButtonLoadingAnimation() : ()
    }
    
    @objc
    func didTapLaterButton() {
        delegate?.tapLaterButton()
    }
    
    @IBAction func back(_ sender: Any) {
        delegate?.back()
    }
    
    func activeButtonForService(isFound: Bool) {
		self.isFound = isFound
        appearLaterButton()
    }
    
    private func appearLaterButton() {
        searchButtonBottomConstraint.priority = UILayoutPriority(rawValue: 999)
        laterButtonTopConstraint.priority = UILayoutPriority(rawValue: 1000)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.laterButton.alpha = 1
        }) { (finished) in
            self.laterButton.isHidden = !finished
        }
    }
}
