//
//  ValetCell.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.04.2021.
//

import UIKit

class ValetCell: UITableViewCell {
    @IBOutlet private weak var backgroundContentView: RoundedView!
    @IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var ticketLabel: UILabel!
	@IBOutlet private weak var cardTypeLabel: UILabel!
	@IBOutlet private weak var statusLabel: UILabel!
	@IBOutlet private weak var watingTimeLabel: UILabel!
	@IBOutlet private weak var recipientPlaceLabel: UILabel!
	
	var data: ParkingTicket? = nil {
		didSet {
			titleLabel.text = data?.title
			ticketLabel.text = data?.ticket
            cardTypeLabel.text = data?.cardType == .ticket ? "Разовая" : "Абонемент"
            statusLabel.text = data?.vehicleDetails?.vehicleStateName ?? "unknown status"
            recipientPlaceLabel.text = "Паркинг -"
            if let lotName = data?.vehicleDetails?.lotName,
               !lotName.isEmpty {
                recipientPlaceLabel.text = "Паркинг \(lotName)"
            }
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundContentView.isLoadable = true
    }
}
