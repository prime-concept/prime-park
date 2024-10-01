import Foundation
import AnyCodable

//swiftlint:disable trailing_whitespace
final class IssuePass: Codable {
    
    final class Visit: Codable {
        let id: Int
        let request: Int
        let cardNumber: String
        let tmCardNumber: String
        let templateName: String
        let created: Date
        let lastUpdated: Date
        let isDeleted: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case request
            case cardNumber
            case tmCardNumber = "tm_card_number"
            case templateName = "template_name"
            case created
            case lastUpdated = "last_updated"
            case isDeleted = "is_deleted"
        }
        
        init(from decoder: Decoder) throws {
            let contatiner = try? decoder.container(keyedBy: CodingKeys.self)
            id = (try? contatiner?.decode(Int.self, forKey: .id)) ?? 0
            request = (try? contatiner?.decode(Int.self, forKey: .request)) ?? 0
            cardNumber = (try? contatiner?.decode(String.self, forKey: .cardNumber)) ?? ""
            tmCardNumber = (try? contatiner?.decode(String.self, forKey: .tmCardNumber)) ?? ""
            templateName = (try? contatiner?.decode(String.self, forKey: .templateName)) ?? ""

            let createdStr = (try? contatiner?.decode(String.self, forKey: .created)) ?? ""
            let lastUpdatedStr = (try? contatiner?.decode(String.self, forKey: .lastUpdated)) ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            created = dateFormatter.date(from: createdStr) ?? Date()
            lastUpdated = dateFormatter.date(from: lastUpdatedStr) ?? Date()
            isDeleted = (try? contatiner?.decode(Bool.self, forKey: .isDeleted)) ?? false
        }
        
        init() {
            id = 0
            request = 0
            cardNumber = "-"
            tmCardNumber = "-"
            templateName = "-"
            created = Date()
            lastUpdated = Date()
            isDeleted = false
        }
    }
    
    var sharedId: Int //if its a issue than sharedId is issueId in other case is passId
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
    var isExpired: Bool
    let dateExit: Date?
    let status: String
    let isDeleted: Bool
    let request: String?
    let results: [IssuePass]
    
    let visit: Visit?
    
    // Pagination part
    let count: Int?
    let next: String?

    enum CodingKeys: String, CodingKey {
        case issueId = "id"
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
        case visit
        case results
        
        case count
        case next
    }

    // swiftlint:disable force_unwrapping function_body_length
    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        let results = (try? container?.decode([IssuePass].self, forKey: .results)) ?? []
        self.request = nil
        self.results = results
        
        self.visit = (try? container?.decode(Visit.self, forKey: .visit))

        self.count = (try? container?.decode(Int.self, forKey: .count)) ?? 0
        self.next = (try? container?.decode(String.self, forKey: .next)) ?? ""
        
        self.dateExit = (try? container?.decode(Date.self, forKey: .dateExit))
        self.issueId = (try? container?.decode(Int.self, forKey: .issueId)) ?? 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateCreate = (try? container?.decode(String.self, forKey: .createdAt)) ?? ""
        let dateStart = (try? container?.decode(String.self, forKey: .startDate)) ?? ""
        let dateEnd = (try? container?.decode(String.self, forKey: .endDate)) ?? ""
        self.createdAt = dateFormatter.date(from: dateCreate) ?? Date()
        self.startDate = dateFormatter.date(from: dateStart) ?? Date()
        self.endDate = dateFormatter.date(from: dateEnd)
        self.descriptionText = (try? container?.decode(String.self, forKey: .descriptionText)) ?? ""
        self.entrance = (try? container?.decode(String.self, forKey: .entrance)) ?? ""
        self.firstName = (try? container?.decode(String.self, forKey: .firstName)) ?? ""
        self.lastName = (try? container?.decode(String.self, forKey: .lastName)) ?? ""
        self.middleName = (try? container?.decode(String.self, forKey: .middleName))
        self.phone = (try? container?.decode(String.self, forKey: .phone)) ?? ""
        self.role = (try? container?.decode(String.self, forKey: .role)) ?? ""
        self.userID = (try? container?.decode(Int.self, forKey: .userID)) ?? 0
        self.room = (try? container?.decode(Int.self, forKey: .room)) ?? 0
        self.place = (try? container?.decode(Int.self, forKey: .place)) ?? 0
        self.employee = (try? container?.decode(Int.self, forKey: .employee)) ?? 0
        self.isService = (try? container?.decode(Bool.self, forKey: .isService)) ?? false
        self.apartmentNumber = (try? container?.decode(String.self, forKey: .apartmentNumber)) ?? ""
        self.floor = (try? container?.decode(Int.self, forKey: .floor)) ?? 0
        self.isExpired = (try? container?.decode(Bool.self, forKey: .isExpired)) ?? false
        self.status = (try? container?.decode(String.self, forKey: .status)) ?? "vanjo"
        self.isDeleted = (try? container?.decode(Bool.self, forKey: .isDeleted)) ?? false

        let typeInt = (try? container?.decode(Int.self, forKey: .type)) ?? 0
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
        
        sharedId = issueId
        if let visit = visit {
            sharedId = visit.id
        }
    }
    
    init() {
        sharedId = 0 //if its a issue than sharedId is issueId in other case is passId
        issueId = 0
        type = .another
        createdAt = Date()
        startDate = Date()
        endDate = nil
        descriptionText = "-"
        entrance = "-"
        firstName = "-"
        lastName = "a"
        middleName = nil
        phone = "-"
        role = "-"
        userID = 0
        room = 0
        place = 0
        employee = 0
        isService = false
        apartmentNumber = "-"
        floor = 0
        isExpired = false
        dateExit = nil
        status = "-"
        isDeleted = false
        request = nil
        results = []
        
        visit = nil
        
        count = nil
        next = nil
    }
}

extension IssuePass: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(issueId)
    }
    
    static func == (lhs: IssuePass, rhs: IssuePass) -> Bool {
        return lhs.issueId == rhs.issueId
    }
}

extension IssuePass {
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
        return dateFormatter.string(from: startDate)
    }
    
    var endDateMedium: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: endDate ?? Date())
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

extension IssuePass {
//	func strFormat() -> String {
//		guard let clearHouse = self.house.components(separatedBy: "/").last else { return "\(self.apartmentNumber)" }
//		return "\(clearHouse)-\(self.apartmentNumber)"
//	}
}

extension IssuePass: CustomStringConvertible {
    var description: String {
        return "issueId: \(issueId), fullName: \(fullName), passType: \(typeDescription), active: \(active), isEpired:\(isExpired), startDate: \(startDate)" + (endDate != nil ? ", endDate: \(endDate ?? Date())" : "")
    }
}

extension IssuePass: Roleable {}
