import Foundation
import AnyCodable

final class Barcode: Codable {
    let companyID: String
    let companyName: String
    let balance: Double
    let models: [BarcodeModel]

    enum CodingKeys: String, CodingKey {
        case companyID = "Id"
        case companyName = "Name"
        case balance = "Balance"
        case models = "BarCodeModels"
    }

    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.companyID = (try? container?.decode(String.self, forKey: .companyID)) ?? ""
        self.companyName = (try? container?.decode(String.self, forKey: .companyName)) ?? ""
        self.balance = (try? container?.decode(Double.self, forKey: .balance)) ?? 0.0
        let modelsDict = (try? container?.decode([[String: AnyCodable]].self, forKey: .models)) ?? []
        var tempModels: [BarcodeModel] = []
        for modelDict in modelsDict {
            let model = BarcodeModel(parameters: modelDict)
            tempModels.append(model)
        }
        self.models = tempModels
    }
}

final class BarcodeModel: Codable {
    let id: String
    let companyID: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case companyID = "CompanyId"
        case name = "Name"
    }

    init(from decoder: Decoder) {
        self.id = ""
        self.companyID = ""
        self.name = ""
    }

    init(parameters: [String: AnyCodable]) {
        self.id = parameters["Id"]?.value as? String ?? ""
        self.companyID = parameters["CompanyId"]?.value as? String ?? ""
        self.name = parameters["Name"]?.value as? String ?? ""
    }
}
