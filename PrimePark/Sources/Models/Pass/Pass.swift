import Foundation
import AnyCodable
// swiftlint:disable trailing_whitespace

enum PassType: Int, Encodable {
    case permanent = 1
    case temporary = 2
    case oneTime = 3
    case oneDay = 4
    case another
}

enum PassStatus: String {
    case onCoordination = "OnCoordination"
    case declined       = "Declined"
    case canceled       = "Canceled"
    case exceeded       = "Exceeded"
    case active         = "Active"
    case used           = "Used"
    case unknown        = "Unknown"
    case perfect        = "Perfect"
}

final class Pass: Codable {
    let passId: Int
    let issueId: Int
    let type: PassType
    let createdAt: Date
    let startDate: Date
    let endDate: Date?
    let descriptionText: String
    let entrance: String
    let firstName: String
    let lastName: String
    let middleName: String?
    let phone: String
    let role: String
    let userID: Int
    let room: Int
    let place: Int
    let employee: Int
    let isService: Bool
    let apartmentNumber: String
    let floor: Int
    let isExpired: Bool
    let dateExit: Date?
    let status: String
    let isDeleted: Bool
    let request: String?
    let results: [Pass]
    
    // Pagination part
    let count: Int?
    let next: String?

    enum CodingKeys: String, CodingKey {
        case passId = "id"
        case issueId
        case type
        case createdAt = "created"
        case startDate = "date_from"
        case endDate = "date_to"
        case descriptionText = "dscription"
        case entrance
        case firstName = "name"
        case lastName = "surname"
        case middleName = "second_name"
        case phone = "phone_number"
        case role
        case userID = "user"
        case room
        case place = "place_id"
        case employee = "employee_id"
        case isService = "is_service"
        case apartmentNumber = "apartment_number"
        case floor
        case isExpired = "is_expired"
        case dateExit = "date_exit"
        case status
        case isDeleted = "is_deleted"
        case request
        case results
        
        case count
        case next
        //case previous
    }

    // swiftlint:disable force_unwrapping function_body_length
    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        let results = (try? container?.decode([Pass].self, forKey: .results)) ?? []
        
        let parameters = (try? container?.decode([String: AnyCodable].self, forKey: .request)) ?? [:]
        self.results = results
        self.request = nil
        
        self.count = (try? container?.decode(Int.self, forKey: .count)) ?? 0
        self.next = (try? container?.decode(String.self, forKey: .next)) ?? ""
        //self.previous = (try? container?.decode(String.self, forKey: .previous)) ?? ""
        
        self.dateExit = (try? container?.decode(Date.self, forKey: .dateExit))
        self.passId = (try? container?.decode(Int.self, forKey: .passId)) ?? 0
        self.issueId = parameters[CodingKeys.passId.rawValue]?.value as? Int ?? 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateCreate = (try? container?.decode(String.self, forKey: .createdAt)) ?? ""
        let dateStart = parameters[CodingKeys.startDate.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .startDate)) ?? ""
        let dateEnd = parameters[CodingKeys.endDate.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .endDate)) ?? ""
        self.createdAt = dateFormatter.date(from: dateCreate) ?? Date()
        self.startDate = dateFormatter.date(from: dateStart) ?? Date()
        self.endDate = dateFormatter.date(from: dateEnd)

        self.descriptionText = parameters[CodingKeys.descriptionText.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .descriptionText)) ?? ""
        self.entrance = parameters[CodingKeys.entrance.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .entrance)) ?? ""
        self.firstName = parameters[CodingKeys.firstName.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .firstName)) ?? ""
        self.lastName = parameters[CodingKeys.lastName.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .lastName)) ?? ""
        self.middleName = parameters[CodingKeys.middleName.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .middleName))
        self.phone = parameters[CodingKeys.phone.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .phone)) ?? ""
        self.role = parameters[CodingKeys.role.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .role)) ?? ""
        self.userID = parameters[CodingKeys.userID.rawValue]?.value as? Int ?? 0//(try? container?.decode(Int.self, forKey: .userID)) ?? 0
        self.room = parameters[CodingKeys.room.rawValue]?.value as? Int ?? 0//(try? container?.decode(Int.self, forKey: .room)) ?? 0
        self.place = parameters[CodingKeys.place.rawValue]?.value as? Int ?? 0//(try? container?.decode(Int.self, forKey: .place)) ?? 0
        self.employee = parameters[CodingKeys.employee.rawValue]?.value as? Int ?? 0//(try? container?.decode(Int.self, forKey: .employee)) ?? 0
        self.isService = parameters[CodingKeys.isService.rawValue]?.value as? Bool ?? false//(try? container?.decode(Bool.self, forKey: .isService)) ?? false
        self.apartmentNumber = parameters[CodingKeys.apartmentNumber.rawValue]?.value as? String ?? ""//(try? container?.decode(String.self, forKey: .apartmentNumber)) ?? ""
        self.floor = parameters[CodingKeys.floor.rawValue]?.value as? Int ?? 0//(try? container?.decode(Int.self, forKey: .floor)) ?? 0
        self.isExpired = parameters[CodingKeys.isExpired.rawValue]?.value as? Bool ?? false//(try? container?.decode(Bool.self, forKey: .isExpired)) ?? false
        self.status = parameters[CodingKeys.status.rawValue]?.value as? String ?? "vanjo"
        self.isDeleted = parameters[CodingKeys.isDeleted.rawValue]?.value as? Bool ?? false

        let typeInt = parameters[CodingKeys.type.rawValue]?.value as? Int ?? 0//(try? container?.decode(Int.self, forKey: .type)) ?? 0
        if let dateTo = self.endDate,
            typeInt == 2 {
            if dateTo == startDate {
                self.type = PassType(rawValue: 4)!
            } else {
                self.type = PassType(rawValue: typeInt)!
            }
        } else {
            if typeInt >= 1 && typeInt <= 4 {
                self.type = PassType(rawValue: typeInt)!
            } else {
                self.type = .another
            }
        }
    }
}

extension Pass {
    var typeDescription: String {
        switch type {
        case .oneTime:
            return Localization.localize("pass.type.onetime")
        case .oneDay:
            return Localization.localize("pass.type.oneDay")
        case .temporary:
            return Localization.localize("pass.type.temporary")
        case .permanent:
            return Localization.localize("pass.type.permanent")
        default:
            return ""
        }
    }
    
    var passStatus: PassStatus {
        return PassStatus(rawValue: status) ?? .unknown
    }

    var createdDateMedium: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: createdAt)
    }

    var fullName: String {
        var nameString = "\(lastName) \(firstName)"
        if let patronymic = middleName {
            nameString += " \(patronymic)"
        }
        return nameString
    }

    var active: Bool {
        if isExpired == true || dateExit != nil || isHistoryByStatus || isDeleted {
            return false
        }
        return true
    }
    
    private var isHistoryByStatus: Bool {
        if passStatus == .used ||
            passStatus == .exceeded ||
            passStatus == .canceled ||
            passStatus == .declined {
            return true
        }
        return false
    }
}

extension Pass: CustomStringConvertible {
    var description: String {
        return "fullName: \(self.fullName) passType: \(self.typeDescription) active: \(self.active)"
    }
}

extension Pass: Roleable {}
