import Foundation
import AnyCodable

final class Guest: NSObject {//Codable { //
    let id: String
    let name: String
    let surname: String
    let patronymic: String?
    let phone: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case surname
        case patronymic
        case phone
    }

    init(from decoder: Decoder) {
        self.id = ""
        self.name = ""
        self.surname = ""
        self.patronymic = ""
        self.phone = ""
    }

    init(params: [String: AnyCodable]) {
        self.id = params[CodingKeys.id.rawValue]?.value as? String ?? ""
        self.name = params[CodingKeys.name.rawValue]?.value as? String ?? ""
        self.surname = params[CodingKeys.surname.rawValue]?.value as? String ?? ""
        self.patronymic = params[CodingKeys.patronymic.rawValue]?.value as? String ?? ""
        self.phone = params[CodingKeys.phone.rawValue]?.value as? String ?? ""
    }

    init(name: String, surname: String, patronymic: String?, phone: String) {
        self.id = UUID().uuidString
        self.name = name
        self.surname = surname
        self.patronymic = patronymic
        self.phone = phone
    }
    
    init(fullName: String, phone: String) {
        self.id = UUID().uuidString
		self.surname = fullName.components(separatedBy: " ")[safe: 0] ?? ""
        self.name = fullName.components(separatedBy: " ")[safe: 1] ?? ""
        self.patronymic = fullName.components(separatedBy: " ")[safe: 2] ?? ""
        self.phone = phone
    }
}

extension Guest {
    var fullName: String {
        var nameString = "\(surname) \(name)"
        if let patronymic = patronymic {
            nameString += " \(patronymic)"
        }
        return nameString
    }

    // swiftlint:disable force_unwrapping
    var shortcutName: String {
        let endIndex = name.index(name.startIndex, offsetBy: 1)
        var nameString = "\(surname) \(name[name.startIndex..<endIndex])."
        if let patronymic = patronymic, !patronymic.isEmpty {
            nameString += "\(patronymic.first!)."
        }
        return nameString
    }
    
    var removePhoneFormat: String {
        let correct = phone.replacingOccurrences(of: " ", with: "")
                           .replacingOccurrences(of: "-", with: "")
        return correct
    }
}
