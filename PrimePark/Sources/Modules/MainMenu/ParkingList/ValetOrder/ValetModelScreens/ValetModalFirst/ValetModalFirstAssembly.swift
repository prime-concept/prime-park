//
//  ValetModalFirstAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//

import Foundation

final class ValetModalFirstAssembly: Assembly {
    private let parkingTicket: ParkingTicket
    
    init(parketTicket: ParkingTicket) {
        self.parkingTicket = parketTicket
    }
    
    func make() -> UIViewController {
        let controller = ValetModalFirstController(parkingTicket: parkingTicket)
        return controller
    }
}
