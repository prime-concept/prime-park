import Foundation

final class CreateRecordResponse: Codable {
    let success: Bool

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.success = (try? container?.decode(Bool.self, forKey: .success)) ?? false
    }
}
