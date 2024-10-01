//
//  ValetTimerAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.05.2021.
//

import Foundation

final class ValetTimerAssembly: Assembly {
    
    private let parkingTicket: ParkingTicket
    private let state: OpeningState
    
    init(
        parkingTicket: ParkingTicket,
        state: OpeningState = .creating(60 * 9)
    ) {
        self.parkingTicket = parkingTicket
        self.state = state
    }
    
    func make() -> UIViewController {
        let presenter = ValetTimerPresenter(parkingTicket: parkingTicket, openingState: state)
        let controller = ValetTimerController(presenter: presenter)
        controller.presenter = presenter
        presenter.controller = controller
        return controller
    }
    
    /// Transition way to ValetTimerController
    enum OpeningState {
        /// Transition to ValetTimerController without request: [getCurrentVehicleStatus(details: VehicleDetails)](x-source-tag://getCurrentVehicleStatus) for car giving
        case creating(TimeInterval)
        /// Transition to ValetTimerController with request: [getCurrentVehicleStatus(details: VehicleDetails)](x-source-tag://getCurrentVehicleStatus) for car giving
        case existing(TimeInterval)
    }
}
