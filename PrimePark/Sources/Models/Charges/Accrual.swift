//
//  Accrual.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 22.03.2021.
//

import Foundation

final class Accrual: Codable {
    let id: String
    let apartmentId: String
    let month: Date
    let service: String
    let value: Double
    let generatedAt: Date
    let paidAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case apartmentId
        case month
        case service
        case value
        case generatedAt
        case paidAt
        case createdAt
        case updatedAt
        case deletedAt
    }
    //swiftlint:disable trailing_whitespace
    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.apartmentId = (try? container?.decode(String.self, forKey: .apartmentId)) ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        let monthStr = (try? container?.decode(String.self, forKey: .month)) ?? ""
        self.month = dateFormatter.date(from: monthStr) ?? Date()
        
        self.service = (try? container?.decode(String.self, forKey: .service)) ?? ""
        self.value = (try? container?.decode(Double.self, forKey: .value)) ?? 0
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let generatedAtStr = (try? container?.decode(String.self, forKey: .generatedAt)) ?? ""
        let paidAtStr = (try? container?.decode(String.self, forKey: .paidAt)) ?? ""
        let createdAtStr = (try? container?.decode(String.self, forKey: .createdAt)) ?? ""
        let updatedAtStr = (try? container?.decode(String.self, forKey: .updatedAt)) ?? ""
        let deletedAtStr = (try? container?.decode(String.self, forKey: .deletedAt)) ?? ""
        
        self.generatedAt = dateFormatter.date(from: generatedAtStr) ?? Date()
        self.paidAt = dateFormatter.date(from: paidAtStr) ?? Date()
        self.createdAt = dateFormatter.date(from: createdAtStr) ?? Date()
        self.updatedAt = dateFormatter.date(from: updatedAtStr) ?? Date()
        self.deletedAt = dateFormatter.date(from: deletedAtStr) ?? Date()
    }
    
    init(month: Date, value: Double, paidAt: Date?) {
        self.month = month
        self.value = value
        self.paidAt = paidAt
        
        self.id = ""
        self.apartmentId = ""
        self.service = ""
        self.createdAt = Date()
        self.updatedAt = Date()
        self.generatedAt = Date()
        self.deletedAt = nil
    }
}

extension Accrual: Hashable {
    
    static func == (lhs: Accrual, rhs: Accrual) -> Bool {
        return lhs.month == rhs.month
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(month)
    }
}

extension Accrual: CustomStringConvertible {
    var description: String {
        "id: \(id), apartmentId: \(apartmentId), month: \(month), service: \(service), value: \(value), generatedAt: \(generatedAt), paidAt: \(paidAt)"
    }
    
    var strMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: month)
    }
    
    var strCurrency: String {
        let intValue = Int(value)
        var resultFormat = "\(intValue) ₽"
        let count = "\(intValue)".count
        let spaceIndex = count >= 4 ? count - 3 : nil
        if let index = spaceIndex {
            resultFormat.insert(contentsOf: " ", at: resultFormat.index(resultFormat.startIndex, offsetBy: index))
        }
        return resultFormat
    }
}

extension Array where Element == Accrual {
    func makeGrouped() -> [Accrual: [Accrual]] {
        var resultDict: [Accrual: [Accrual]] = [:]
        var dictionary: [String: [Accrual]] = [:]
        guard let key = self.first?.strMonth else { return [:] }
        self.forEach {
            if var value = dictionary[key] {
                value.append($0)
                dictionary.updateValue(value, forKey: key)
            } else {
                dictionary.updateValue([$0], forKey: key)
            }
        }
        
        dictionary.values.forEach {
            let monthSum = $0.map { $0.value }.reduce(0.0) { $0 + $1 }
            let paidAt = $0.first?.paidAt
            let month = $0.first?.month ?? Date()
            let values = Array($0)
            resultDict.updateValue(values, forKey: Accrual(month: month, value: monthSum, paidAt: paidAt))
        }
        return resultDict
    }
}
