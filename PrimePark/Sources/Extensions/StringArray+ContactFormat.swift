import NaturalLanguage
import Contacts

extension CNContact {
    var phoneNumber: String {
        return Converting.phoneNumberWithContryCode(contact: self).first ?? "unknown"
    }
    var toString: String {
        if givenName.isEmpty && familyName.isEmpty {
            return phoneNumber
        }
        return "\(givenName) \(familyName)"
    }
}

fileprivate extension Array where Element == String {
    subscript(checkIndex index: Int) -> String {
        var copyIndex = index
        while self[copyIndex].isEmpty && copyIndex < self.count - 1 {
            copyIndex += 1
        }
        return self[copyIndex]
    }
}

extension CNContact: Comparable {
    public static func < (lhs: CNContact, rhs: CNContact) -> Bool {
        let lhsArr = [
            lhs.familyName,
            lhs.givenName,
            lhs.phoneNumber
        ]
        let rhsArr = [
            rhs.familyName,
            rhs.givenName,
            rhs.phoneNumber
        ]
        return lhsArr[checkIndex: 0] < rhsArr[checkIndex: 0]
    }
}

enum Language: Int, Codable {
    case russian
    case english
}

extension Language {
    static func convertToLanguage(_ input: String) -> Self {
        switch input {
        case "en":
            return .english
        case "ru":
            return .russian
        default:
            return .russian
        }
    }
}

extension Language: CustomStringConvertible {
    var description: String {
        switch self {
        case .english:
            return "en"
        case .russian:
            return "ru"
        }
    }
}

func alphabet(of language: Language) -> [String] {
    switch language {
    case .english:
        return [
                "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
                "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
        ]
    case .russian:
        return [
                "А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П",
                "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ь", "Ы", "Ъ", "Э", "Ю", "Я"
        ]
    }
}

func contactTableFormat(_ language: Language, _ contacts: [CNContact]) -> [(title: String, contacts: [CNContact])] {
    var contactDictionary = [String: [CNContact]]()
    var contactSectionsTitles = [String]()
    let checking = Set(alphabet(of: language))
    for contact in contacts {
        var contactKey = String(contact.familyName.prefix(1)).isEmpty ?
                         String(contact.givenName.prefix(1)) : String(contact.familyName.prefix(1))
        contactKey = contactKey.capitalized
        if var contactValues = contactDictionary[contactKey] {
            contactValues.append(contact)
            contactDictionary[contactKey] = contactValues
        } else {
            contactDictionary[contactKey] = [contact]
        }
        contactSectionsTitles = [String](contactDictionary.keys)
        contactSectionsTitles = contactSectionsTitles.sorted()
    }
    var unknownCase: [[CNContact]] = []
    for contactsKey in contactDictionary.keys {
        if !checking.isSuperset(of: Set(arrayLiteral: contactsKey)) {
            unknownCase.append(contactDictionary[contactsKey] ?? [])
            contactDictionary[contactsKey] = nil
        }
    }
    contactDictionary["#"] = Array(unknownCase.joined())
    var tuple: [(title: String, contacts: [CNContact])] = contactDictionary.sorted { $0.0 < $1.0 }.map { ($0.key, $0.value) }
    tuple.append(tuple.removeFirst())
    tuple[tuple.endIndex - 1].contacts.sort(by: <)
    return tuple
}
