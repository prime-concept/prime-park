//
//  NotificationsDemoEndpoint.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 02.04.2021.
//

import Foundation

final class NotificationsDemoEndpoint: PrimeParkEndpoint {
    private static let notifyMeEndpoint = "/primepark/me/notify"
    
    func testNotify(token: String) -> EndpointResponse<EmptyResponse> {
        let endpoint = Self.notifyMeEndpoint + "/"
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.create(endpoint: endpoint, parameters: nil, headers: headers)
    }
}
