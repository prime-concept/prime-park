//
//  Invoice.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 08.04.2021.
//
//swiftlint:disable trailing_whitespace

import Foundation

final class Invoice: Codable {
    let createdAt: Date
    let balance: Int
    let month: Date
    let accountType: String
    let generatedAt: Date?
    let invoice: String?
    let accountNumber: String
    let value: Int
    let apartmentId: String
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case balance
        case month
        case accountType
        case generatedAt
        case invoice
        case accountNumber
        case value
        case apartmentId
        case updatedAt
    }
    
    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        let createdAtStr = (try? container?.decode(String.self, forKey: .createdAt)) ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.yyyy"
        self.createdAt = dateFormatter.date(from: createdAtStr) ?? Date()
        self.balance = (try? container?.decode(Int.self, forKey: .balance)) ?? 0
        
        let monthStr = (try? container?.decode(String.self, forKey: .month)) ?? ""
        dateFormatter.dateFormat = "MM.yyyy"
        self.month = dateFormatter.date(from: monthStr) ?? Date()
        
        self.accountType = (try? container?.decode(String.self, forKey: .accountType)) ?? ""
        
        let generatedAtStr = (try? container?.decode(String.self, forKey: .generatedAt)) ?? ""
        self.generatedAt = dateFormatter.date(from: generatedAtStr)
        
        self.invoice = (try? container?.decode(String.self, forKey: .invoice))
        self.accountNumber = (try? container?.decode(String.self, forKey: .accountNumber)) ?? ""
        self.value = (try? container?.decode(Int.self, forKey: .value)) ?? 0
        self.apartmentId = (try? container?.decode(String.self, forKey: .apartmentId)) ?? ""
        
        let updatedAtStr = (try? container?.decode(String.self, forKey: .updatedAt)) ?? ""
        self.updatedAt = dateFormatter.date(from: updatedAtStr) ?? Date()
    }
}

extension Invoice {
    var strMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = LocalAuthService.shared.getCurrentLocale()
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
