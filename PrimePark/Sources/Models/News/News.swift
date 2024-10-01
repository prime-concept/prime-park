import Foundation
import AnyCodable

final class News: Codable {
    let id: String
    let title: String
    let text: String
    let active: Bool
    let createdAt: Date
    let updatedAt: Date
    let image: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case text
        case active
        case createdAt
        case updatedAt
        case image
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.title = (try? container?.decode(String.self, forKey: .title)) ?? ""
        self.text = (try? container?.decode(String.self, forKey: .text)) ?? ""
        self.active = (try? container?.decode(Bool.self, forKey: .active)) ?? true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        //dateFormatter.timeZone = TimeZone(identifier: "GMT")//Calendar.current.timeZone
        let dateCreate = (try? container?.decode(String.self, forKey: .createdAt)) ?? ""
        let dateUpdate = (try? container?.decode(String.self, forKey: .updatedAt)) ?? ""
        self.createdAt = dateFormatter.date(from: dateCreate) ?? Date()
        self.updatedAt = dateFormatter.date(from: dateUpdate) ?? Date()
        self.image = (try? container?.decode(String.self, forKey: .image)) ?? ""
    }
}

extension News: CustomStringConvertible {
    var description: String {
        return "id: \(id), title: \(title), text: \(text), active: \(active), createdAt: \(createdAt), updatedAt: \(updatedAt), image: \(image)"
    }
}
