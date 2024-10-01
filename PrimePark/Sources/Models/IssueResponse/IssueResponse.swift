import Foundation
import AnyCodable
//swiftlint:disable trailing_whitespace
final class IssueResponse: Codable {
    let id: Int
    let requestId: Int
    let type: PassType
    let name: String
    let surname: String
    let role: String
    let user: Int
    let room: Int
    let street: String
    let house: String
    let floor: Int
    let address: String
    let placeId: Int
    let employeeId: Int
    let secondName: String
    let phoneNumber: String
    let dateFrom: Date
    let dateTo: Date
    let isService: Bool
    let created: Date
    let lastUpdated: Date
    let isExpired: Bool
    let apartmentNumber: String
    let request: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case request
        case type
        case name
        case surname
        case role
        case user
        case room
        case street
        case house
        case floor
        case address
        case placeId = "place_id"
        case employeeId = "employee_id"
        case secondName = "second_name"
        case phoneNumber = "phone_number"
        case dateFrom = "date_from"
        case dateTo = "date_to"
        case isService = "is_service"
        case created
        case lastUpdated = "last_updated"
        case isExpired = "is_expired"
        case apartmentNumber = "apartment_number"
    }
    
    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        let parameters = (try? container?.decode([String: AnyCodable].self, forKey: .request)) ?? [:]
        self.request = nil
        
        self.id = (try? container?.decode(Int.self, forKey: .id)) ?? 0
        self.requestId = parameters[CodingKeys.id.rawValue]?.value as? Int ?? 0
        
        let typeInt = parameters[CodingKeys.type.rawValue]?.value as? Int ?? 0
        self.type = PassType(rawValue: typeInt) ?? .another
        
        self.name = parameters[CodingKeys.name.rawValue]?.value as? String ?? ""
        self.surname = parameters[CodingKeys.surname.rawValue]?.value as? String ?? ""
        self.role = parameters[CodingKeys.role.rawValue]?.value as? String ?? ""
        self.user = parameters[CodingKeys.user.rawValue]?.value as? Int ?? 0
        self.room = parameters[CodingKeys.room.rawValue]?.value as? Int ?? 0
        self.street = parameters[CodingKeys.street.rawValue]?.value as? String ?? ""
        self.house = parameters[CodingKeys.house.rawValue]?.value as? String ?? ""
        self.floor = parameters[CodingKeys.floor.rawValue]?.value as? Int ?? 0
        self.address = parameters[CodingKeys.address.rawValue]?.value as? String ?? ""
        self.placeId = parameters[CodingKeys.placeId.rawValue]?.value as? Int ?? 0
        self.employeeId = parameters[CodingKeys.employeeId.rawValue]?.value as? Int ?? 0
        self.secondName = parameters[CodingKeys.secondName.rawValue]?.value as? String ?? ""
        self.phoneNumber = parameters[CodingKeys.phoneNumber.rawValue]?.value as? String ?? ""
        self.isService = parameters[CodingKeys.isService.rawValue]?.value as? Bool ?? true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFromStr = (try? container?.decode(String.self, forKey: .dateFrom)) ?? ""
        let dateToStr = (try? container?.decode(String.self, forKey: .dateTo)) ?? ""
        let createdStr = (try? container?.decode(String.self, forKey: .created)) ?? ""
        let lastUpdatedStr = (try? container?.decode(String.self, forKey: .lastUpdated)) ?? ""
        
        self.dateFrom = dateFormatter.date(from: dateFromStr) ?? Date()
        self.dateTo = dateFormatter.date(from: dateToStr) ?? Date()
        self.created = dateFormatter.date(from: createdStr) ?? Date()
        self.lastUpdated = dateFormatter.date(from: lastUpdatedStr) ?? Date()
        self.isExpired = parameters[CodingKeys.isExpired.rawValue]?.value as? Bool ?? true
        self.apartmentNumber = parameters[CodingKeys.apartmentNumber.rawValue]?.value as? String ?? ""
    }
}
