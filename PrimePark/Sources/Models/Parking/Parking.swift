import Foundation
import AnyCodable

enum ParkingType: Int, Encodable {
    case onetime = 1
    case permanent = 2
    case valet = 3
}

final class Parking: Codable {
    let id: String
    let companyID: String
    let room: Int
    let carNumber: String
    let carModel: String
    let phone: String
    let name: String
    let usageTime: String
    let created: Date
    let type: ParkingType

    enum CodingKeys: String, CodingKey {
        case id
        case companyID = "company_id"
        case room
        case carNumber = "guest_plate_number"
        case carModel = "guest_car_model"
        case phone = "guest_phone_number"
        case name = "guest_name"
        case usageTime = "usage_time"
        case created = "created"
        case type
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.companyID = (try? container?.decode(String.self, forKey: .companyID)) ?? ""

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let dateCreate = (try? container?.decode(String.self, forKey: .created)) ?? ""
        self.created = dateFormatter.date(from: dateCreate) ?? Date()

        self.room = (try? container?.decode(Int.self, forKey: .room)) ?? 0
        self.carNumber = ((try? container?.decode(String.self, forKey: .carNumber)) ?? "").uppercased()
        self.carModel = (try? container?.decode(String.self, forKey: .carModel)) ?? ""
        self.phone = (try? container?.decode(String.self, forKey: .phone)) ?? ""
        self.name = (try? container?.decode(String.self, forKey: .name)) ?? ""
        self.usageTime = (try? container?.decode(String.self, forKey: .usageTime)) ?? ""
        self.type = .onetime
    }
    
    init() {
        id = "-"
        companyID = "-"
        room = 0
        carNumber = "-"
        carModel = "-"
        phone = "-"
        name = "-"
        usageTime = "-"
        created = Date()
        type = .onetime
    }
}

extension Parking {
    var typeDescription: String {
        switch type {
        case .onetime:
            return Localization.localize("parking.type.onetime")
        case .permanent:
            return Localization.localize("parking.type.permanent")
        case .valet:
            return Localization.localize("parking.type.valet")
        }
    }

    var createdDateMedium: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: created)
    }

    /*var active: Bool {
        if isExpired {
            return false
        }
        if let dateTo = endDate {
            return dateTo >= Date.startOfCurrentDate()
        } else {
            return startDate >= Date.startOfCurrentDate()
        }
    }*/
}
