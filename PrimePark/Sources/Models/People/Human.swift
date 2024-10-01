import Foundation
import AnyCodable

final class Human: Codable { //NSObject {//
    let id: String
    let name: String
    let phone: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case role
    }

    init(from decoder: Decoder) {
        self.id = ""
        self.name = ""
        self.phone = ""
        self.role = ""
    }

    init(params: [String: AnyCodable]) {
        self.id = params[CodingKeys.id.rawValue]?.value as? String ?? ""
        self.name = params[CodingKeys.name.rawValue]?.value as? String ?? ""
        self.phone = params[CodingKeys.phone.rawValue]?.value as? String ?? ""
        self.role = params[CodingKeys.role.rawValue]?.value as? String ?? ""
    }

    init(name: String, phone: String, role: String) {
        self.id = UUID().uuidString
        self.name = name
        self.phone = phone
        self.role = role
    }
}

extension Human: Roleable {}
