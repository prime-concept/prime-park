import Foundation
import AnyCodable

final class User: Codable {
    let verified: Bool
    let username: String
    let enabled: Bool
    let email: String
    let phone: String
    let firstName: String
    let lastName: String
    let middleName: String
    let grantedAuthorities: [String]
    let clubCard: String?
    var rooms: [[String: AnyCodable]]//[Room]
    var avatar: String
    var domaId: String

    enum CodingKeys: String, CodingKey {
        case verified
        case enabled
        case grantedAuthorities
        case username
        case email
        case phone
        case firstName
        case middleName
        case lastName
        case clubCard
        case rooms
        case avatar
        case domaId
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.verified = (try? container?.decode(Bool.self, forKey: .verified)) ?? false
        self.username = (try? container?.decode(String.self, forKey: .username)) ?? ""
        self.enabled = (try? container?.decode(Bool.self, forKey: .enabled)) ?? false
        self.email = (try? container?.decode(String.self, forKey: .email)) ?? ""
        self.phone = (try? container?.decode(String.self, forKey: .phone)) ?? ""
        self.firstName = (try? container?.decode(String.self, forKey: .firstName)) ?? ""
        self.middleName = (try? container?.decode(String.self, forKey: .middleName)) ?? ""
        self.lastName = (try? container?.decode(String.self, forKey: .lastName)) ?? ""
        self.grantedAuthorities = (try? container?.decode(Array.self, forKey: .grantedAuthorities)) ?? []
        self.clubCard = (try? container?.decode(String.self, forKey: .clubCard)) ?? ""
        self.avatar = (try? container?.decode(String.self, forKey: .avatar)) ?? ""
        self.rooms = (try? container?.decode([[String: AnyCodable]].self, forKey: .rooms)) ?? []
        self.domaId = (try? container?.decode(String.self, forKey: .domaId)) ?? ""
        /*let roomsArray: [[String: AnyCodable]] = (try? container?.decode([[String: AnyCodable]].self, forKey: .rooms)) ?? []
        self.rooms = []
        for roomItem in roomsArray {
            let room = Room(params: roomItem)
            rooms.append(room)
        }*/
    }

    func getFullName() -> String {
        let name = "\(firstName) \(middleName) \(lastName)"
        return name
    }
}

extension User {
    var shortFullName: String {
        var shortName = String(firstName.first ?? Character(" "))
        var shortSecondname = String(middleName.first ?? Character(" "))
        shortName = shortName == " " ? shortName : "\(shortName)."
        shortSecondname = shortSecondname == " " ? shortSecondname : "\(shortSecondname)."
        return "\(lastName) \(shortName) \(shortSecondname)"
    }
    
    var defaultRoom: Room? {
        for room in parcingRooms {
            if room.id == 851 || room.id == 856 {
                return room
            }
        }
        return nil
    }

    var parcingRooms: [Room] {
        var tempRooms: [Room] = []
        for roomItem in rooms {
            let room = Room(params: roomItem)
            tempRooms.append(room)
        }
        return tempRooms
    }
}

final class Room: Codable {
    let id: Int
    let number: String
    let buildingID: Int
    let buildingName: String
    let street: String
    let house: String
    let entrance: String
    let floor: String
    let address: String
    let apartmentNumber: String
    let building: [String: AnyCodable]
    var role: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case number
        case building = "building"
        case buildingName = "name"
        case street = "street"
        case house = "house"
        case entrance = "entrance"
        case floor = "floor"
        case address = "address"
        case apartmentNumber = "apartment_number"
        case role = "role"
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = (try? container?.decode(Int.self, forKey: .id)) ?? 0
        self.number = (try? container?.decode(String.self, forKey: .number)) ?? ""
        self.street = (try? container?.decode(String.self, forKey: .street)) ?? ""
        self.house = (try? container?.decode(String.self, forKey: .house)) ?? ""
        self.entrance = (try? container?.decode(String.self, forKey: .entrance)) ?? "99"
        self.floor = (try? container?.decode(String.self, forKey: .floor)) ?? ""
        self.address = (try? container?.decode(String.self, forKey: .address)) ?? ""
        self.apartmentNumber = (try? container?.decode(String.self, forKey: .apartmentNumber)) ?? ""
        self.role = (try? container?.decode(String.self, forKey: .role)) ?? ""

        self.building = (try? container?.decode([String: AnyCodable].self, forKey: .building)) ?? [:]
        self.buildingID = self.building[CodingKeys.id.rawValue]?.value as? Int ?? 0
        self.buildingName = self.building[CodingKeys.buildingName.rawValue]?.value as? String ?? ""
    }

    init(params: [String: AnyCodable]) {
        self.id = params[CodingKeys.id.rawValue]?.value as? Int ?? 0
        self.number = params[CodingKeys.number.rawValue]?.value as? String ?? ""
        self.street = params[CodingKeys.street.rawValue]?.value as? String ?? ""
        self.house = params[CodingKeys.house.rawValue]?.value as? String ?? ""
        self.entrance = params[CodingKeys.entrance.rawValue]?.value as? String ?? ""
        self.floor = params[CodingKeys.floor.rawValue]?.value as? String ?? ""
        self.address = params[CodingKeys.address.rawValue]?.value as? String ?? ""
        self.apartmentNumber = params[CodingKeys.apartmentNumber.rawValue]?.value as? String ?? ""
        self.role = params[CodingKeys.role.rawValue]?.value as? String ?? ""

        let buildingDictionary: [String: Any] = params[CodingKeys.building.rawValue]?.value as? Dictionary ?? Dictionary()
        self.building = [:]

        self.buildingID = buildingDictionary[CodingKeys.id.rawValue] as? Int ?? 0
        self.buildingName = buildingDictionary[CodingKeys.buildingName.rawValue] as? String ?? ""
    }
}

extension Room: CustomStringConvertible {
    var description: String {
        return "id: \(self.id) house: \(self.house) apartmentNumber: \(self.apartmentNumber) entrance: \(self.entrance)"
    }
}

extension Room {
    func getRoomIndex(_ rooms: [Room]) -> Int? {
        return rooms.firstIndex { $0.id == self.id }
    }
}

extension Room {
    func strFormat() -> String {
        guard let clearHouse = self.house.components(separatedBy: "/").last else { return "\(self.apartmentNumber)" }
        return "\(clearHouse)-\(self.apartmentNumber)"
    }
}

extension Room {
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
}

final class AccessToken: Codable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    let expiresIn: Int
    let scope: String

    var expireDate: Date {
        Date().addingTimeInterval(TimeInterval(self.expiresIn))
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case scope = "scope"
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.accessToken = (try? container?.decode(String.self, forKey: .accessToken)) ?? ""
        self.tokenType = (try? container?.decode(String.self, forKey: .tokenType)) ?? ""
        self.refreshToken = (try? container?.decode(String.self, forKey: .refreshToken)) ?? ""
        self.expiresIn = (try? container?.decode(Int.self, forKey: .expiresIn)) ?? 0
        self.scope = (try? container?.decode(String.self, forKey: .scope)) ?? ""
    }
}

extension Room: Roleable {}
