final class ServiceType: Codable {
    let id: String
    let type: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name = "display_name"
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.type = (try? container?.decode(Int.self, forKey: .type)) ?? 0
        self.name = (try? container?.decode(String.self, forKey: .name)) ?? ""
    }
}
