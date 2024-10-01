import Foundation

final class BLEConfig: Codable {
    let id: String
    let room: Int
    let type: Int
    var configFile: String
    let aesKey: String
    let dateExit: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case room
        case type
        case configFile = "config"
        case aesKey = "aes_key"
        case dateExit = "date_exit"
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.id = UUID().uuidString
        self.type = (try? container?.decode(Int.self, forKey: .type)) ?? 0
        self.room = (try? container?.decode(Int.self, forKey: .room)) ?? 0
        self.configFile = (try? container?.decode(String.self, forKey: .configFile)) ?? ""
        self.aesKey = (try? container?.decode(String.self, forKey: .aesKey)) ?? ""
        self.dateExit = (try? container?.decode(Date.self, forKey: .dateExit))
    }
}

extension BLEConfig {
    var aesKeyData: Data {
        return self.aesKey.data(using: .bytesHexLiteral) ?? Data()
    }

    var configData: Data {
        return self.configFile.data(using: .bytesHexLiteral) ?? Data()
    }
}
