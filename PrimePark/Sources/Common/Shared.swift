import Foundation

let appId = "9a63c5e7-01e0-4000-8ff7-deabbd976f3e"

enum WebViewLinksConstants {
    static let parkValet = "https://request.o-valet.com/ov?ln=ru"
}

enum WebViewInfoLinksConstants {
    static let roleInfoLink = "https://primeparkmanagement.ru/role"
    static let passInfoLink = "https://primeparkmanagement.ru/access"
    static let parkInfoLink = "https://primeparkmanagement.ru/parking"
    static let parkValet    = "https://primeparkmanagement.ru/valet"
    static let lawInfo      = "https://primeparkmanagement.ru/legal"
}

enum ChatIdType: String {
    case callBackID     = "c763de06-df36-4852-86b4-1c10021da0c8"
    case securityChatID = "df6c4716-5574-4431-9285-2889efd253fd"
    case helpChatID     = "4a83e5d0-bf5c-47f3-a739-636cbef4d45a"
}

enum ChatIdIssue: String {
    case cleaning       = "7acc2601-94f7-4e4f-befa-cfe009ddfce2"
    case services       = "631152af-65ee-4e62-8c74-b3671f28c0d2"
    case different      = "d68e277d-adff-4550-ba27-b6b1092f3c21"
    case parking        = "39582cf5-4d13-4b71-a4ee-ca907935bc39"
    case charges        = "05e1d74f-01b9-427b-b817-48464f8af5cb"
    case dryCleaning    = "30c82567-58aa-40f6-8120-2e69b1061de7"
    case carWash        = "8e8c3515-bbde-43a9-ab90-36f07445c0cf"
    case pass           = "ee2d7428-9460-46e6-a18e-05f03a77d2cc"
    case security       = "5b09b88a-46cc-44dc-a8f5-f2855949a1b2"
    case help           = "4a83e5d0-bf5c-47f3-a739-636cbef4d45a"
}

enum CreateParkingIssues: String {
    case privateValetParking    = "f1dd3d57-9c08-412e-9a49-70d9405e4ef4"
    case privateParking         = "860250ee-a093-46ea-ae73-c6ac74748517"
    
    init?(rawValue: String) {
        switch rawValue {
        case "Private абонемент":
            self = .privateParking
        case "Valet абонемент":
            self = .privateValetParking
        default:
            self = .privateParking
        }
    }
}

extension CreateParkingIssues {
    var name: String {
        switch self {
        case .privateParking:
            return "Private абонемент"
        case .privateValetParking:
            return "Valet абонемент"
        }
    }
}

enum Entrance: Int {
    case central = 0
    case service
}

extension Entrance {
    static func entranceBy(_ isService: Bool) -> Entrance {
        return isService ? .service : .central
    }
}

extension Entrance {
    var localizedName: String {
        switch self {
        case .central:
            return localizedWith("createPass.entrance.front")
        default:
            return localizedWith("createPass.entrance.service")
        }
    }
}

enum Role: String {
    case resident   = "inhabitant"
    case cohabitant = "cohabitant"
    case brigadier  = "brigadier"
    case guest      = "guest"
}

protocol Roleable {
    var role: String { get }
    var getRole: Role { get }
}

extension Roleable {
    var getRole: Role {
        switch role {
        case String(describing: Role.resident):
            return .resident
        case String(describing: Role.cohabitant):
            return .cohabitant
        case String(describing: Role.brigadier):
            return .brigadier
        case String(describing: Role.guest):
            return .guest
        default:
            return .resident
        }
    }
}

//swiftlint:disable identifier_name
struct BarCodeName {
    static let CENTRAL_ENTRANCE_RESIDENT_PAY    = "Разовый, парадный вход-за счет жителя"
    static let CENTRAL_ENTRANCE_GUEST_PAY       = "Разовый, парадный вход-за счет гостя"
    static let SERVICE_ENTRANCE_RESIDENT_PAY    = "Разовый, служебный вход-за счет жителя"
    static let SERVICE_ENTRANCE_GUEST_PAY       = "Разовый, служебный вход-за счет гостя"
}

protocol LanguageChangingProtocol {
    func subscribeOnLanguageChanging()
    func updateLanguage(notification: NSNotification?)
}

func currentLanguage(notification: NSNotification, key: String) -> String {
    guard let languageCode = (notification.userInfo?["numberOfLanguage"] ?? 0) as? Int,
          let language = Language(rawValue: languageCode) else { return "ru" }
    let languageString = language.description
    let currentLanguage = key.localized(languageString)
    return currentLanguage
}
