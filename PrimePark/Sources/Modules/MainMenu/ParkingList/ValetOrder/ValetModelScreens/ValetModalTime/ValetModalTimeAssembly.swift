//
//  ValetModalTimeAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//

import Foundation

final class ValetModalTimeAssembly: Assembly {
    
    private let parkingTicket: ParkingTicket
    
    init(parkingTicket: ParkingTicket) {
        self.parkingTicket = parkingTicket
    }
    
    func make() -> UIViewController {
        let presenter = ValetModalTimePresenter(parkingTicket: parkingTicket)
        let controller = ValetModalTimeController(presenter: presenter)
        controller.presenter = presenter
        presenter.controller = controller
        return controller
    }
}
