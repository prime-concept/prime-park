import Contacts

final class Converting {

    static func phoneNumberWithContryCode(contact: CNContact) -> [String] {

        var arrPhoneNumbers = [String]()
        for contctNumVar: CNLabeledValue in contact.phoneNumbers {
            let fulMobNumVar: CNPhoneNumber = contctNumVar.value
            //let countryCode = fulMobNumVar.value(forKey: "countryCode") get country code
            if let mccNamVar = fulMobNumVar.value(forKey: "digits") as? String {
                arrPhoneNumbers.append(mccNamVar)
            }
        }
        return arrPhoneNumbers // here array has all contact numbers.
    }
}
