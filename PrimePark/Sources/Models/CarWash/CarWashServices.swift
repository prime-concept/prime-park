import Foundation

final class CarWashServices: Codable {
    let data: [CarWashService]

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.data = (try? container?.decode([CarWashService].self, forKey: .data)) ?? []
    }
}

final class CarWashService: Codable {
    let id: Int
    let title: String
    let staff: [Staff]
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container?.decode(Int.self, forKey: .id)) ?? 0
        self.title = (try? container?.decode(String.self, forKey: .title)) ?? ""
        self.staff = (try? container?.decode([Staff].self, forKey: .staff)) ?? []
    }
}

// MARK: - Staff
final class Staff: Codable {
    let id: Int
    let seanceLength: Int

    enum CodingKeys: String, CodingKey {
        case id
        case seanceLength = "seance_length"
    }

    init(id: Int, seanceLength: Int) {
        self.id = id
        self.seanceLength = seanceLength
    }
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container?.decode(Int.self, forKey: .id)) ?? 0
        self.seanceLength = (try? container?.decode(Int.self, forKey: .seanceLength)) ?? 0
    }
}

struct ServicesViewModel {
    let id: Int
    let title: String
    let staffId: Int
    let seanceLength: Int
    var isSelected: Bool
}

extension ServicesViewModel {
    static func makeAsViewModel(from service: CarWashService) -> ServicesViewModel {
        let id = service.id
        let title = service.title
        let staff = service.staff.count > 1 ? service.staff[1] : service.staff[0]
        let staffId = staff.id
        let seanceLength = staff.seanceLength
        return ServicesViewModel(
            id: id,
            title: title,
            staffId: staffId,
            seanceLength: seanceLength,
            isSelected: false
        )
    }
}
