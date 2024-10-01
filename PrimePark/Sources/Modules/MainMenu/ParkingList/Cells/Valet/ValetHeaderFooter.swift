//
//  ValetHeaderFooter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.04.2021.
//

import UIKit

protocol ValetOrderProtocol: AnyObject {
    func order(type: ParkingTicket.CardType)
}

class ValetHeaderFooter: UITableViewHeaderFooterView {
    
    @IBOutlet weak var actualContentView: RoundedView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createButton: LocalizableButton!
    
    private(set) var ticketType: ParkingTicket.CardType = .all
    
    weak var delegate: ValetOrderProtocol?
    
    @IBAction func createTap(_ sender: Any) {
        delegate?.order(type: ticketType)
    }
    
    func changeStyle(to: ParkingTicket.CardType) {
        switch to {
        case .ticket:
            ticketType = .ticket
            actualContentView.backgroundColor = UIColor(hex: 0x41262D)
            createButton.alpha = 1
            titleLabel.text = localizedWith("parking.valet.guestCard")
        case .subscription:
            ticketType = .subscription
            actualContentView.backgroundColor = UIColor(hex: 0x363636)
            createButton.alpha = 0
            titleLabel.text = localizedWith("parking.valet.subscription")
        case .all:
            break
        }
    }
}
