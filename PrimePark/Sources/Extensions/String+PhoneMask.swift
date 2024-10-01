import libPhoneNumber_iOS
//swiftlint:disable all
extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
    // Authorization screen
    
    func addPhoneMask(country: CountryCode) -> String {
        var template = Array(country.maskDisplayable)
        let array = Array(self)
        print(array)
        var iterator = 0
        for i in template.indices {
            if array.count - 1 < iterator { break }
            if template[i] == "_" {
                template[i] = array[iterator]
                iterator += 1
            } else {
                continue
            }
        }
        return String(template)
    }

    func addCodeMask() -> String {
        switch self.count {
        case 0:
            return "_____"
        case 1:
            return "\(self)____"
        case 2:
            return "\(self)___"
        case 3:
            return "\(self)__"
        case 4:
            return "\(self)_"
        case 5:
            return "\(self)"
        default:
            return self
        }
    }

    func deleteMask() -> String {
        let text = self.replacingOccurrences(
            of: #"(-|_|\s)"#,
            with: "",
            options: [.literal, .regularExpression],
            range: nil
        )
        return text
    }
    
    // Other screens
    
    func addPassMask() -> String {
        let array = Array(self)
        var phoneString = ""
        array.forEach { phoneString += String($0) }
        var formattedString: String = phoneString
        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(phoneString, defaultRegion: "")
            formattedString = try phoneUtil.format(phoneNumber, numberFormat: .INTERNATIONAL)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return formattedString
    }

    func addPhoneMaskForProfile() -> String {
        let array = Array(self)
        return "\(array[0]) \(array[1])\(array[2])\(array[3]) \(array[4])\(array[5])\(array[6])-\(array[7])\(array[8])-\(array[9])\(array[10])"
    }
}

enum CountryPhoneMask: String {
    case RU         = "+X XXX XXX-XX-XX"
    case BR         = "+XXX XX XXX-XX-XX"
    case GR         = "+XX XXXX XXXXXX"
    case UNKNOWN    = "+XXXXXXXXXXXXXX"
}

extension CountryPhoneMask {
    static func detectCountryCode(number: String) -> Self {
        let clearNumbers = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let countryCode = clearNumbers.prefix(4)
        switch countryCode {
        case _ where countryCode.first == "7" || countryCode.first == "8":
            return .RU
        case _ where countryCode.contains("375"):
            return .BR
        case _ where countryCode.contains("49"):
            return .GR
        default:
            return .UNKNOWN
        }
    }
}

func format(with mask: CountryPhoneMask, phone: String) -> String {
    let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    var result = ""
    var index = numbers.startIndex
    for char in mask.rawValue where index < numbers.endIndex {
        if char == "X" {
            result.append(numbers[index])
            index = numbers.index(after: index)
        } else {
            result.append(char)
        }
    }
    //check RUS format that begins with 8 and change on +7
    if mask == .RU {
        var arr = Array(result)
        if arr.count >= 2 {
            arr[1] = "7"
        }
        result = String(arr)
    }
    return result
}
