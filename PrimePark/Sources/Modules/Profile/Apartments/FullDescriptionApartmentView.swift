//
//  ApartmentsView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 22.01.2021.
//

import UIKit

protocol ApartmentsViewDelegate: class {
    func back()
    func changeApartment()
}
//swiftlint:disable trailing_whitespace
class FullDescriptionApartmentView: UIView {
    @IBOutlet weak var apartmentLabel: UILabel!
    @IBOutlet weak var customerReferenceLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var entranceLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var apartmentNumberLabel: UILabel!
    
    private weak var delegate: ApartmentsViewDelegate?
    var currentRoom: Room?
    
    func setDelegate(_ delegate: ApartmentsViewDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func chooseApartments(_ sender: Any) {
        print("choose")
        self.delegate?.changeApartment()
    }
    @IBAction func back(_ sender: Any) {
        delegate?.back()
    }
}

extension FullDescriptionApartmentView: ApplyingLabelProtocol {
    func applyRoomFormat(format: String, currentRoom: Room) {
        apartmentLabel.text = format
        self.currentRoom = currentRoom
        
        self.customerReferenceLabel.text = currentRoom.number
        self.streetLabel.text = currentRoom.street
        self.houseLabel.text = currentRoom.house
        self.entranceLabel.text = currentRoom.entrance
        self.floorLabel.text = currentRoom.floor
        self.apartmentNumberLabel.text = currentRoom.apartmentNumber
    }
}
