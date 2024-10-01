//
//  VehicleState.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 30.03.2022.
//

import Foundation

final class VehicleState: Decodable {
    let isRequested: Int
    let requestedForDate: String
    let requestedRemainingSec: Int
    
    enum CodingKeys: String, CodingKey {
        case isRequested = "vehicle_is_requested"
        case requestedForDate = "vehicle_requested_for_dt"
        case requestedRemainingSec = "vehicle_requested_remaining_sec"
    }
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        isRequested = (try? container?.decode(Int.self, forKey: .isRequested)) ?? 0
        requestedForDate = (try? container?.decode(String.self, forKey: .requestedForDate)) ?? ""
        requestedRemainingSec = (try? container?.decode(Int.self, forKey: .requestedRemainingSec)) ?? 0
    }
}
