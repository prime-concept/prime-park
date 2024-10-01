import Foundation
import AnyCodable

final class Resident: Codable {
    let id: String
    let name: String
    let surname: String
    let secondName: String
    let phone: String
    let email: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case surname
        case secondName = "second_name"
        case phone = "phone_number"
        case email
        case role
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.name = (try? container?.decode(String.self, forKey: .name)) ?? ""
        self.surname = (try? container?.decode(String.self, forKey: .surname)) ?? ""
        self.secondName = (try? container?.decode(String.self, forKey: .secondName)) ?? ""
        self.phone = (try? container?.decode(String.self, forKey: .phone)) ?? ""
        self.email = (try? container?.decode(String.self, forKey: .email)) ?? ""
        self.role = (try? container?.decode(String.self, forKey: .role)) ?? ""
    }

    init(name: String, surname: String, patronymic: String?, phone: String, role: String) {
        self.id = UUID().uuidString
        self.name = name
        self.surname = surname
        self.secondName = patronymic ?? ""
        self.phone = phone
        self.role = role
        self.email = ""
    }
}

extension Resident {
    var fullName: String {
        return "\(name) \(surname) \(secondName)"
    }
    var shortFullName: String {
        var shortName = String(name.first ?? Character(" "))
        var shortSecondname = String(secondName.first ?? Character(" "))
        shortName = shortName == " " ? shortName : "\(shortName)."
        shortSecondname = shortSecondname == " " ? shortSecondname : "\(shortSecondname)."
        return "\(surname) \(shortName) \(shortSecondname)"
    }

    var roleDescription: String {
        switch role {
        case "inhabitant":
            return localizedWith("resident.role.inhabitant")
        case "cohabitant":
            return localizedWith("resident.role.cohabitant")
        case "brigadier":
            return localizedWith("resident.role.brigadier")
        case "guest":
            return localizedWith("resident.role.guest")
        default:
            return ""
        }
    }
    
    var removePhoneFormat: String {
        let correct = phone.replacingOccurrences(of: " ", with: "")
                           .replacingOccurrences(of: "-", with: "")
        return correct
    }
}

extension Resident: Roleable {}
