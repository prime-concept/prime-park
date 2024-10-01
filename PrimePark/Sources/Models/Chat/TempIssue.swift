import Foundation
import AnyCodable

final class TempIssue: Codable {
    let id: String
    let number: Int

    enum CodingKeys: String, CodingKey {
        case id
        case number
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.number = (try? container?.decode(Int.self, forKey: .number)) ?? 0
    }
}
