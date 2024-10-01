import Foundation

final class Timeslots: Codable {
    let data: [Timeslot]

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.data = (try? container?.decode([Timeslot].self, forKey: .data)) ?? []
    }
}

final class Timeslot: Codable {
    let time: String
    let datetime: String
    let seanceLength: Int

    enum CodingKeys: String, CodingKey {
        case time
        case seanceLength = "seance_length"
        case datetime
    }

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.time = (try? container?.decode(String.self, forKey: .time)) ?? ""
        self.datetime = (try? container?.decode(String.self, forKey: .datetime)) ?? ""
        self.seanceLength = (try? container?.decode(Int.self, forKey: .seanceLength)) ?? 0
    }
}

extension Timeslot {
    func getDate() -> Date {
        self.datetime.date("yyyy-MM-dd'T'HH:mm:ssZ") ?? Date()
    }
}
