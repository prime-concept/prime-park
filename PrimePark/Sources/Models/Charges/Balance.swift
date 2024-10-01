//
//  Balance.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 24.03.2021.
//

import Foundation

final class Balance: Codable {
    let saldo: Double
    let toPay: Double
    
    enum CodingKeys: String, CodingKey {
        case saldo
        case toPay
    }
    
    init(from decoder: Decoder) {
        let containter = try? decoder.container(keyedBy: CodingKeys.self)
        
        saldo = (try? containter?.decode(Double.self, forKey: .saldo)) ?? 0
        toPay = (try? containter?.decode(Double.self, forKey: .toPay)) ?? 0
    }
}

extension Balance {
    var strCurrency: String {
        var resultFormat = "\(saldo) ₽"
        let count = "\(Int(saldo))".count
        let spaceIndex = count >= 4 ? count - 3 : nil
        if let index = spaceIndex {
            resultFormat.insert(contentsOf: " ", at: resultFormat.index(resultFormat.startIndex, offsetBy: index))
        }
        return resultFormat
    }
}
