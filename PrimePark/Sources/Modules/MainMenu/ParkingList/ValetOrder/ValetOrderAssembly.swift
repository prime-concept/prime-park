//
//  ValetOrderAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.05.2021.
//

import Foundation
import UIKit

final class ValetOrderAssembly: Assembly {
    
    private let parkingTicket: ParkingTicket
    private let isExistingCard: Bool
    
    init(parkingTicket: ParkingTicket, isExistingCard: Bool = false) {
        self.parkingTicket = parkingTicket
        self.isExistingCard = isExistingCard
    }
    
    func make() -> UIViewController {
        let presenter = ValetOrderPresenter(parkingTicket: parkingTicket)
        let controller = ValetOrderController(presenter: presenter, isExistingCard: isExistingCard)
        presenter.controller = controller
        controller.presenter = presenter
        return controller
    }
}
