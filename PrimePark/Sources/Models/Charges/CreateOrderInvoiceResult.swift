//
//  CreateOrderInvoiceResult.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 08.06.2021.
//
// swiftlint:disable vertical_whitespace
import Foundation

final class Payment: Decodable {
    let id: String?
    let orderId: String?
    let status: String?
    let paymentId: String?
    let paymentUrl: String?
    //let operation: String
    let sberStatus: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case orderId
        case status
        case paymentId
        case paymentUrl
        //case operation
        case sberStatus = "sber_status"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        orderId = try? container.decode(String.self, forKey: .orderId)
        status = try? container.decode(String.self, forKey: .status)
        paymentId = try? container.decode(String.self, forKey: .paymentId)
        paymentUrl = try? container.decode(String.self, forKey: .paymentUrl)
        sberStatus = try? container.decode(Int.self, forKey: .sberStatus)
    }
    
    init() {
        id = ""
        orderId = ""
        status = ""
        paymentId = ""
        paymentUrl = ""
        sberStatus = nil
    }
}

extension Payment: CustomStringConvertible {
    var description: String {
        return "Payment: id: \(id), orderId: \(orderId), status: \(status), paymentId: \(paymentId), paymentUrl: \(paymentUrl), sberStatus: \(sberStatus)"
    }
}


final class CreateOrderInvoiceResult: Decodable {
    final class Product: Decodable {
        let quantity: Int
        let amount: Int
    }
    
    final class Order: Decodable {
        let id: String
        let number: Int
        let totalAmount: Int
        
        let products: [Product]
    }
    
    let order: Order
    let payment: Payment
}
