import Foundation

final class CarWashHistory: Codable {
    let data: DataClass

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.data = (try? container?.decode(DataClass.self, forKey: .data)) ?? DataClass(records: [])
    }
}

final class DataClass: Codable {
    let records: [Record]

    init(records: [Record]) {
        self.records = records
    }
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.records = (try? container?.decode([Record].self, forKey: .records)) ?? []
    }
}

final class Record: Codable {
    let id: Int
    let comment, date: String
    let visitID: Int
    let services: [WashService]

    enum CodingKeys: String, CodingKey {
        case id, comment, date
        case visitID = "visit_id"
        case services
    }
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container?.decode(Int.self, forKey: .id)) ?? 0
        self.comment = (try? container?.decode(String.self, forKey: .comment)) ?? ""
        self.date = (try? container?.decode(String.self, forKey: .date)) ?? ""
        self.visitID = (try? container?.decode(Int.self, forKey: .visitID)) ?? 0
        self.services = (try? container?.decode([WashService].self, forKey: .services)) ?? []
    }
}

// MARK: - Service
final class WashService: Codable {
    let id: Int
    let title: String
    let costToPay: Int

    enum CodingKeys: String, CodingKey {
        case id, title
        case costToPay = "cost_to_pay"
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.id = (try? container?.decode(Int.self, forKey: .id)) ?? 0
        self.title = (try? container?.decode(String.self, forKey: .title)) ?? ""
        self.costToPay = (try? container?.decode(Int.self, forKey: .costToPay)) ?? 0
    }
}

struct HistoryRecordViewModel {
    let id: Int
    let title: String
    let comment: String
    let date: String
    let dateAndTime: String
    let cost: Int
}

extension HistoryRecordViewModel {
    static func makeAsViewModel(from record: Record) -> HistoryRecordViewModel {
        let id = record.id
        let comment = record.comment
        let formatter = DateFormatter()
        let date = record.date.date("yyyy-MM-dd HH:mm:ss")
        let dateString = date?.string("yy.MM.dd")
        let dateAndTimeString = date?.string("dd.MM.yyyy, HH:mm")
        let title = record.services.first?.title ?? ""
        let cost = record.services.first?.costToPay ?? 0
        return HistoryRecordViewModel(
            id: id,
            title: title,
            comment: comment,
            date: dateString ?? "",
            dateAndTime: dateAndTimeString ?? "",
            cost: cost
        )
    }
}
