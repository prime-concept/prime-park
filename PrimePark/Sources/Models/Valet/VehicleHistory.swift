//
//  VehicleHistory.swift
//  VehicleHistory
//
//  Created by Vanjo Lutik on 05.12.2021.
//

import Foundation

final class VehicleHistory: Decodable {
    let stateName: String
    let subStateName: String
    let dateTimeLocal: String
    
    let vehicleHistory: [VehicleHistory]
    
    enum CodingKeys: String, CodingKey {
        case stateName = "state_name"
        case subStateName = "sub_state_name"
        case dateTimeLocal = "date_time_local"
        
        case vehicleHistory = "vehicle_history"
    }
    
    init() {
        stateName = ""
        subStateName = ""
        dateTimeLocal = ""
        
        vehicleHistory = []
    }
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        vehicleHistory = (try? container?.decode([VehicleHistory].self, forKey: .vehicleHistory)) ?? []
        
        self.stateName = (try? container?.decode(String.self, forKey: .stateName)) ?? ""
        self.subStateName = (try? container?.decode(String.self, forKey: .subStateName)) ?? ""
        
        self.dateTimeLocal = (try? container?.decode(String.self, forKey: .dateTimeLocal)) ?? ""
    }
}

extension VehicleHistory {
    var actual: VehicleHistory {
        return vehicleHistory.first ?? VehicleHistory()
    }
    
    var formattedTime: Date {
        print("formattedTime: \(actual.dateTimeLocal.date/*.addingTimeInterval(3600)*/)")
        return actual.dateTimeLocal.date/*.addingTimeInterval(3600)*/
    }
    
    var current: Int {
        Int(Date().dateWithCurrentTimeZone() - formattedTime)
    }
}
