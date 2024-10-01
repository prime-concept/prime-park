//
//  OrderInvoiceData.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 08.06.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation


final class OrderInvoiceData: Decodable {
    let id: String
    let number: Int
    let totalAmount: Int
    let room: String
    let product: String
    let quantity: Int
    let amount: Int
    let account: String
    let created: Date
    let lastUpdated: Date
    let payment: Payment
    
    enum CodingKeys: String, CodingKey {
        case id
        case number
        case totalAmount = "total_amount"
        case room
        case product
        case quantity
        case amount
        case account
        case created
        case lastUpdated = "last_updated"
        case payment
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? ""
        number = (try? container.decode(Int.self, forKey: .number)) ?? 0
        totalAmount = (try? container.decode(Int.self, forKey: .totalAmount)) ?? 0
        room = (try? container.decode(String.self, forKey: .room)) ?? ""
        product = (try? container.decode(String.self, forKey: .product)) ?? ""
        quantity = (try? container.decode(Int.self, forKey: .quantity)) ?? 0
        amount = (try? container.decode(Int.self, forKey: .amount)) ?? 0
        account = (try? container.decode(String.self, forKey: .account)) ?? ""
        
        let createdStr = (try? container.decode(String.self, forKey: .created)) ?? ""
        let lastUpdatedStr = (try? container.decode(String.self, forKey: .lastUpdated)) ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        created = dateFormatter.date(from: createdStr) ?? Date()
        lastUpdated = dateFormatter.date(from: lastUpdatedStr) ?? Date()
        
        payment = (try? container.decode(Payment.self, forKey: .payment)) ?? Payment()
    }
}

extension OrderInvoiceData: CustomStringConvertible {
    var description: String {
        return "id: \(id), number: \(number), totalAmount: \(totalAmount), room: \(room), quantity: \(quantity), amount: \(amount), account: \(account), created: \(created), lastUpdated: \(lastUpdated), payment: \(payment)"
    }
}

