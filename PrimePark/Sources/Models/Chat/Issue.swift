import Foundation
import AnyCodable

enum IssueStatus: String, Encodable {
    case accepted //принята
    case assigned //назначено
    case checking
    case closed
    case completed //выполнено
    case inModeration
    case inWork
    case onRoad //в пути
    case reopened
}

final class Issue: Codable {//NSObject {
    let id: String
    let type: IssueType
    let status: IssueStatus
    let number: Int
    let createdAt: Date
    let updateAt: Date
    let executeStartDate: Date
    let executeEndDate: Date
    let guestsAmount: Int
    let descriptionText: String
    let watchers: Bool
    let unreadCommentsCountInhabitant: Int //Кол-во непрочтенных комментариев жильца
    let unreadCommentsCountEmployee: Int //Кол-во непрочтенных комментариев УК
    var channelUnreadComments: Int = 0
    let creator: String
    let executor: String
    let responsible: String
    let inhabitant: String
    let address: String
    let section: Int
    let floor: Int
    let apartment: String

    private let greenColor = UIColor(hex: 0x36AC54)
    private let redColor = UIColor(hex: 0xFF6B71)
    private let orangeColor = UIColor(hex: 0xE29840)

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case status
        case number
        case createdAt
        case updateAt
        case executeStartDate = "startAt"
        case executeEndDate = "endAt"
        case guestsAmount
        case descriptionText = "reasonText"
        case watchers
        case unreadCommentsCountInhabitant
        case unreadCommentsCountEmployee
        case creator
        case executor
        case responsible
        case inhabitant
        case address = "building"
        case section
        case floor
        case apartment
    }

    // swiftlint:disable force_unwrapping
    // swiftlint:disable function_body_length
    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        let tempStatus = (try? container?.decode(String.self, forKey: .status)) ?? "checking"
        self.status = IssueStatus(rawValue: tempStatus)!
        self.number = (try? container?.decode(Int.self, forKey: .number)) ?? 0
        let dateCreate = (try? container?.decode(Double.self, forKey: .createdAt)) ?? 0
        let updateDate = (try? container?.decode(Double.self, forKey: .updateAt)) ?? 0
        let dateStartExecute = (try? container?.decode(Double.self, forKey: .executeStartDate)) ?? 0
        let dateEndExecute = (try? container?.decode(Double.self, forKey: .executeEndDate)) ?? 0
        self.createdAt = Date(timeIntervalSince1970: dateCreate / 1000)
        self.updateAt = Date(timeIntervalSince1970: updateDate / 1000)
        self.executeStartDate = Date(timeIntervalSince1970: dateStartExecute / 1000)
        self.executeEndDate = Date(timeIntervalSince1970: dateEndExecute / 1000)
        self.guestsAmount = (try? container?.decode(Int.self, forKey: .guestsAmount)) ?? 0
        self.descriptionText = (try? container?.decode(String.self, forKey: .descriptionText)) ?? ""
        self.watchers = (try? container?.decode(Bool.self, forKey: .watchers)) ?? false
        self.unreadCommentsCountInhabitant = (try? container?.decode(Int.self, forKey: .unreadCommentsCountInhabitant)) ?? 0
        self.unreadCommentsCountEmployee = (try? container?.decode(Int.self, forKey: .unreadCommentsCountEmployee)) ?? 0

        let typeObject: [String: AnyCodable] = (try? container?.decode([String: AnyCodable].self, forKey: .type)) ?? [:]
        self.type = IssueType(from: typeObject)

        let creator: [String: String] = (try? container?.decode([String: String].self, forKey: .creator)) ?? [:]
        let creatorFirstName = creator["firstName"]
        let creatorMiddleName = creator["lastName"]
        let creatorLastName = creator["middleName"]
        self.creator = "\(String(describing: creatorLastName)) \(String(describing: creatorFirstName)) \(String(describing: creatorMiddleName))"

        let executor: [String: String] = (try? container?.decode([String: String].self, forKey: .executor)) ?? [:]
        let executorFirstName = executor["firstName"]
        let executorMiddleName = executor["lastName"]
        let executorLastName = executor["middleName"]
        self.executor = "\(String(describing: executorLastName)) \(String(describing: executorFirstName)) \(String(describing: executorMiddleName))"

        let responsible: [String: String] = (try? container?.decode([String: String].self, forKey: .responsible)) ?? [:]
        let responsibleFirstName = responsible["firstName"]
        let responsibleMiddleName = responsible["lastName"]
        let responsibleLastName = responsible["middleName"]
        self.responsible = "\(String(describing: responsibleLastName)) \(String(describing: responsibleFirstName)) \(String(describing: responsibleMiddleName))"

        let inhabitant: [String: String] = (try? container?.decode([String: String].self, forKey: .inhabitant)) ?? [:]
        let inhabitantFirstName = inhabitant["firstName"]
        let inhabitantMiddleName = inhabitant["lastName"]
        let inhabitantLastName = inhabitant["middleName"]
        self.inhabitant = "\(String(describing: inhabitantLastName)) \(String(describing: inhabitantFirstName)) \(String(describing: inhabitantMiddleName))"

        let building: [String: String] = (try? container?.decode([String: String].self, forKey: .address)) ?? [:]
        self.address = building["address"] ?? ""

        let section: [String: String] = (try? container?.decode([String: String].self, forKey: .section)) ?? [:]
        self.section = Int(section["number"] ?? "0") ?? 0

        let floor: [String: String] = (try? container?.decode([String: String].self, forKey: .floor)) ?? [:]
        self.floor = Int(floor["number"] ?? "0") ?? 0

        let apartment: [String: String] = (try? container?.decode([String: String].self, forKey: .apartment)) ?? [:]
        self.apartment = apartment["title"] ?? ""
    }
    
    init() {
        id = ""
        type = .init(id: "", name: "")
        status = .accepted
        number = 0
        createdAt = Date()
        updateAt = Date()
        executeStartDate = Date()
        executeEndDate = Date()
        guestsAmount = 0
        descriptionText = ""
        watchers = false
        unreadCommentsCountInhabitant = 0
        unreadCommentsCountEmployee = 0
        channelUnreadComments = 0
        creator = ""
        executor = ""
        responsible = ""
        inhabitant = ""
        address = ""
        section = 0
        floor = 0
        apartment = ""
    }
}

extension Issue {
    var typeDesctiption: String {
        return self.type.name
        /*switch self.type.type {
        case 0:
            return Localization.localize("concierge.issueType.parking")
        case 1:
            return Localization.localize("concierge.issueType.pass")
        case 2:
            return Localization.localize("concierge.issueType.security")
        default:
            return Localization.localize("concierge.issueType.pass")
        }*/
    }

    var imageName: String {
        #warning("Не понятно, как определять тип и выводить картинку")
        return "chat_pass"
        /*switch self.type.type {
        case 0:
            return "chat_parking"
        case 1:
            return"chat_pass"
        case 2:
            return "chat_security"
        default:
            return "chat_pass"
        }*/
    }

    var statusDescription: String {
        switch self.status {
        case .accepted:
            return Localization.localize("concierge.issueStatus.accepted")
        case .assigned:
            return Localization.localize("concierge.issueStatus.assigned")
        case .checking:
            return Localization.localize("concierge.issueStatus.checking")
        case .closed:
            return Localization.localize("concierge.issueStatus.closed")
        case .completed:
            return Localization.localize("concierge.issueStatus.completed")
        case .inModeration:
            return Localization.localize("concierge.issueStatus.inModeration")
        case .inWork:
            return Localization.localize("concierge.issueStatus.inWork")
        case .onRoad:
            return Localization.localize("concierge.issueStatus.onRoad")
        case .reopened:
            return Localization.localize("concierge.issueStatus.reopened")
        }
    }

    var statusColor: UIColor {
        switch self.status {
        case .accepted:
            return UIColor(hex: 0x4CAF50)
        case .assigned:
            return UIColor(hex: 0x4CAF50)
        case .checking:
            return UIColor(hex: 0x4CAF50)
        case .closed:
            return UIColor(hex: 0x696969)
        case .completed:
            return UIColor(hex: 0x696969)
        case .inModeration:
            return UIColor(hex: 0x4CAF50)
        case .inWork:
            return UIColor(hex: 0x4CAF50)
        case .onRoad:
            return UIColor(hex: 0x4CAF50)
        case .reopened:
            return UIColor(hex: 0x4CAF50)
        }
    }

    var guestsDescription: String {
        var tempGuestString = ""
        switch self.guestsAmount % 10 {
        case 1:
            if (self.guestsAmount / 10) % 10 == 1 {
                tempGuestString = Localization.localize("concierge.issueGuestEnding.1")
            } else {
                tempGuestString = Localization.localize("concierge.issueGuestEnding.other")
            }
        case 2...4:
            if (self.guestsAmount / 10) % 10 == 1 {
                tempGuestString = Localization.localize("concierge.issueGuestEnding.2_4")
            } else {
                tempGuestString = Localization.localize("concierge.issueGuestEnding.other")
            }
        default:
            tempGuestString = Localization.localize("concierge.issueGuestEnding.other")
        }
        return "\(self.guestsAmount) \(tempGuestString)"
    }

    var executeDateDescription: String {
        let dateFormatter = DateFormatter()
        if self.executeStartDate == self.executeEndDate {
            dateFormatter.dateFormat = "dd MMMM"
            let date = dateFormatter.string(from: self.executeStartDate)
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.string(from: self.executeStartDate)
            return "\(date) \(Localization.localize("concierge.in")) \(time)"
        } else {
            dateFormatter.dateFormat = "dd"
            let startDate = dateFormatter.string(from: self.executeStartDate)
            dateFormatter.dateFormat = "dd MMMM"
            let endDate = dateFormatter.string(from: self.executeEndDate)
            dateFormatter.dateFormat = "HH:mm"
            let time = dateFormatter.string(from: self.executeEndDate)
            return "\(startDate)-\(endDate) \(Localization.localize("concierge.in")) \(time)"
        }
    }

    var createDateDescription: String {
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd MMMM"
        let date = dateFormatter.string(from: self.createdAt)
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: self.createdAt)
        return "\(date) \(Localization.localize("concierge.in")) \(time)"
    }
}

extension Issue: CustomStringConvertible {
    var description: String {
        return "(id: \(self.id) type: \(self.type.id) status: \(self.status.rawValue))"
    }
}

final class IssueType: Codable {
    let id: String
    let type: Int
    let name: String
    let isActive: Bool
    var subtypes: [IssueType]

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name = "display_name"
        case isActive = "is_active"
        case subtypes = "subtype"
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.type = (try? container?.decode(Int.self, forKey: .type)) ?? 0
        self.name = (try? container?.decode(String.self, forKey: .name)) ?? ""
        self.isActive = (try? container?.decode(Bool.self, forKey: .isActive)) ?? false
        let subtypesArray: [[String: AnyCodable]] = (try? container?.decode([[String: AnyCodable]].self, forKey: .subtypes)) ?? []
        self.subtypes = []
        for subtype in subtypesArray {
            let type = IssueType(from: subtype)
            self.subtypes.append(type)
        }
    }

    init(from dictionary: [String: AnyCodable]) {
        self.id = dictionary["id"]?.value as? String ?? ""
        self.type = dictionary["type"]?.value as? Int ?? 0
        self.name = dictionary["display_name"]?.value as? String ?? ""
        self.isActive = dictionary["is_active"]?.value as? Bool ?? true
        let subtypesArray: [[String: AnyCodable]] = dictionary["subtype"]?.value as? [[String: AnyCodable]] ?? []
        self.subtypes = []
        for subtype in subtypesArray {
            let type = IssueType(from: subtype)
            self.subtypes.append(type)
        }
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.type = 0
        self.isActive = true
        self.subtypes = []
    }
}

extension IssueType: CustomStringConvertible {
    var description: String {
        return "id:\(self.id), name:\(name), subtypes:\(subtypes)"
    }
}
