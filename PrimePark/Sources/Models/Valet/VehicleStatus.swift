//
//  VehicleStatus.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.05.2021.
//
//swiftlint:disable trailing_whitespace force_try
import Foundation

final class VehicleStatus: Decodable {
    enum State: String {
        case parked = "Parked"
    }
    let secondsRemaining: Int?
    let currentState: String
    let currentDriverAssigned: Driver
    let beingRetrievedDriver: String
    let balanceDue: Double
    
    enum CodingKeys: String, CodingKey {
        case secondsRemaining = "seconds_remaining"
        case currentState = "current_state"
        case currentDriverAssigned = "current_driver_assigned"
        case beingRetrievedDriver = "being_retrieved_driver"
        case balanceDue = "balance_due"
    }
}

extension VehicleStatus: CustomStringConvertible {
    var description: String {
        return "secondsRemaining: \(secondsRemaining), currentState: \(currentState), currentDriverAssigned: \(currentDriverAssigned), beingRetrievedDriver: \(beingRetrievedDriver), balanceDue: \(balanceDue)"
    }
}

final class Driver: Decodable {
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

extension Driver: CustomStringConvertible {
    var description: String {
        return "firstName: \(firstName), lastName: \(lastName)"
    }
}
