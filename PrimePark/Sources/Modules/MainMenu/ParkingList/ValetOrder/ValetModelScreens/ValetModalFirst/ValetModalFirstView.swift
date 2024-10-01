//
//  ValetModalFirstView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//
// swiftlint:disable trailing_whitespace
import UIKit

protocol ValetModalFirstViewDelegate: class {
    func orderParkingNow()
    func differentTime()
}

class ValetModalFirstView: UIView {
    
    weak var delegate: ValetModalFirstViewDelegate?
    
    func commonInit(delegate: ValetModalFirstViewDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func orderParking(_ sender: Any) {
        delegate?.orderParkingNow()
    }
    
    @IBAction func different(_ sender: Any) {
        delegate?.differentTime()
    }
}
/*
 request created: path = https://api.primeconcept.co.uk/v3/primepark/valet/requestVehicle
     method = get
     params = Optional(["m": 9, "t": "PPR11", "p": 665321])
     headers = Optional(["Authorization": "Bearer df4cebd7-a5b6-496e-a039-66e74700e0bf", "Content-Type": "application/json"])
 
 
 request created: path = https://api.primeconcept.co.uk/v3/primepark/valet/requestVehicle
     method = get
     params = Optional(["m": 9, "t": "PP97", "p": 831])
     headers = Optional(["Content-Type": "application/json", "Authorization": "Bearer df4cebd7-a5b6-496e-a039-66e74700e0bf"])
 */
