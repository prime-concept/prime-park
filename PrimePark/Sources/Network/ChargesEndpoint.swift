//
//  ChargesEndpoint.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 23.03.2021.
//
//swiftlint:disable trailing_whitespace
import Foundation
import Alamofire

final class ChargesEndpoint: PrimeParkEndpoint {
    private static let invoicesListEndpoint         = "/primepark/doma_ai/invoices/"                    // {roomId}
    private static let accrualsListEndpoint         = "/primepark/doma_ai/accruals/"                    // {roomId}
    private static let balanceEndpoint              = "/primepark/doma_ai/balance/"                     // {roomId}
    private static let countersListEndpoint         = "/primepark/doma_ai/counters/"                    // {roomId}
    private static let countersHistoryListEndpoint  = "/primepark/doma_ai/counters/{roomId}/history/"    // {roomId}
    
    private static let depositEndpoint              = "/primepark/order/invoice"
    private static let orderEndpoint                = "/primepark/order/{id}"
    
    // mock
    
    private static let mockAccrualsListEndpoint = "/accruals.json"
    
    func getInvoices(room: String, token: String) -> EndpointResponse<[Invoice]> {
        let endpoint = Self.invoicesListEndpoint + room + "/"
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: endpoint, parameters: nil, headers: headers)
    }
    
    func getBalance(room: String, token: String) -> EndpointResponse<Balance> {
        let endpoint = Self.balanceEndpoint + room + "/"
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: endpoint, parameters: nil, headers: headers)
    }
    
    func getAccruals(room: String, token: String) -> EndpointResponse<[Accrual]> {
        let endpoint = Self.accrualsListEndpoint + room + "/"/*Self.mockAccrualsListEndpoint*/
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: endpoint, parameters: nil, headers: headers)
    }
    
    func getCounters(room: String, token: String) -> EndpointResponse<[Counter]> {
        let endpoint = Self.countersListEndpoint + room + "/"
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: endpoint, parameters: nil, headers: headers)
    }
    
    func getCountersHistory(room: String, token: String) -> EndpointResponse<[Counter]> {
        var endpoint = Self.countersHistoryListEndpoint
        endpoint = endpoint.replacingOccurrences(of: "{roomId}", with: room)
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: endpoint, parameters: nil, headers: headers)
    }
    
    func depositAccount(
        room: Int,
        amount: Double,
        token: String,
        returnURL: String
    ) -> EndpointResponse<CreateOrderInvoiceResult> {
        let endpoint = Self.depositEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["room"] = room
        params["amount"] = amount
        params["return_url"] = returnURL
        return self.create(endpoint: endpoint, parameters: params, headers: headers, encoding: JSONEncoding.default)
    }
    
    func checkDeposit(
        orderId: String,
        token: String
    ) -> EndpointResponse<OrderInvoiceData> {
        let endpoint = Self.orderEndpoint.replacingOccurrences(of: "{id}", with: "\(orderId)") 
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: endpoint, parameters: nil, headers: headers)
    }
}
