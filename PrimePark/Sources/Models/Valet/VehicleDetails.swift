//
//  VehicleDetails.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.05.2021.
//
//swiftlint:disable trailing_whitespace
import Foundation

final class VehicleDetails: Decodable {
    let ticketId: String?
    let ticketSimpleValue: String?
    let ticketBarcode: String?
    let vehicleStateId: Int?
    let vehicleStateName: String?
    let vehicleSubStateId: Int?
    let vehicleSubStateName: String?
    let vehicleMake: String?
    let vehicleModel: String?
    let vehicleColor: String?
    let vehicleYear: String?
    let vehicleLicense: String?
    let vehicleIsEv: Int?
    let vehicleIsRequested: Int?
    let vehicleRequestedForDt: String?
    var vehicleRequestedForDtLocal: String?
    
    var vehicleRemainingSec: Int?
    let entName: String?
    let lotName: String?
    
    var vehicleRequestedRemainingSec: Int?
    var vehicleStartRequestTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case ticketId = "ticket_id"
        case ticketSimpleValue = "ticket_simple_value"
        case ticketBarcode = "ticket_barcode"
        case vehicleStateId = "vehicle_state_id"
        case vehicleStateName = "vehicle_state_name"
        case vehicleSubStateId = "vehicle_sub_state_id"
        case vehicleSubStateName = "vehicle_sub_state_name"
        case vehicleMake = "vehicle_make"
        case vehicleModel = "vehicle_model"
        case vehicleColor = "vehicle_color"
        case vehicleYear = "vehicle_year"
        case vehicleLicense = "vehicle_license"
        case vehicleIsEv = "vehicle_is_ev"
        case vehicleIsRequested = "vehicle_is_requested"
        case vehicleRequestedForDt = "vehicle_requested_for_dt"
        case vehicleRequestedForDtLocal = "vehicle_requested_for_dt_local"
        case vehicleRequestedRemainingSec = "vehicle_requested_remaining_sec"
        case entName = "ent_name"
        case lotName = "lot_name"
    }
	
	init(from decoder: Decoder) throws {
		let container = try? decoder.container(keyedBy: CodingKeys.self)
		
		ticketId = try? container?.decode(String.self, forKey: .ticketId)
		ticketSimpleValue = try? container?.decode(String.self, forKey: .ticketSimpleValue)
		ticketBarcode = try? container?.decode(String.self, forKey: .ticketBarcode)
		vehicleStateId = try? container?.decode(Int.self, forKey: .vehicleStateId)
		vehicleStateName = try? container?.decode(String.self, forKey: .vehicleStateName)
		vehicleSubStateId = try? container?.decode(Int.self, forKey: .vehicleSubStateId)
		vehicleSubStateName = try? container?.decode(String.self, forKey: .vehicleSubStateName)
		vehicleMake = try? container?.decode(String.self, forKey: .vehicleMake)
		vehicleModel = try? container?.decode(String.self, forKey: .vehicleModel)
		vehicleColor = try? container?.decode(String.self, forKey: .vehicleColor)
		vehicleYear = try? container?.decode(String.self, forKey: .vehicleYear)
        vehicleLicense = try? container?.decode(String.self, forKey: .vehicleLicense)
		vehicleIsEv = try? container?.decode(Int.self, forKey: .vehicleIsEv)
		vehicleIsRequested = try? container?.decode(Int.self, forKey: .vehicleIsRequested)
		vehicleRequestedForDt = try? container?.decode(String.self, forKey: .vehicleRequestedForDt)
		vehicleRequestedForDtLocal = try? container?.decode(String.self, forKey: .vehicleRequestedForDtLocal)
		vehicleRequestedRemainingSec = try? container?.decode(Int.self, forKey: .vehicleRequestedRemainingSec)
        entName = try? container?.decode(String.self, forKey: .entName)
        lotName = try? container?.decode(String.self, forKey: .lotName)
	}
}

extension VehicleDetails {
    var getFullTime: Int {
        guard let secondsRemain = vehicleRequestedRemainingSec,
              secondsRemain > 0,
              let requestDateStr = vehicleRequestedForDtLocal
        else { return -1 }
        
        print("AAA secondsRemain = \(secondsRemain)")
        print("AAA requestDateStr = \(requestDateStr)")
        
        let fromStartToCurrentDateDiff = Int(Date().dateWithCurrentTimeZone() - requestDateStr.date.addingTimeInterval(-3600))
        
        print("AAA getFullTime: \(fromStartToCurrentDateDiff)")
        
        return fromStartToCurrentDateDiff + secondsRemain
    }
}
