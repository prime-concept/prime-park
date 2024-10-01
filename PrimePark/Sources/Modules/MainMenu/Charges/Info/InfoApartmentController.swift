//
//  InfoApartmentController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 16.03.2021.
//

import UIKit

class InfoApartmentController: UIViewController {
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var entranceLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let apartment = LocalAuthService.shared.apartment {
            streetLabel.text = apartment.street
            houseLabel.text = apartment.house
            entranceLabel.text = apartment.entrance
            floorLabel.text = apartment.floor
            roomLabel.text = apartment.apartmentNumber
        }
    }
}
