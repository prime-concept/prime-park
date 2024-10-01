//
//  TenantStatus.swift
//  TenantStatus
//
//  Created by Vanjo Lutik on 26.12.2021.
//

import Foundation

final class TenantStatus: Decodable {
    let result: String
    let error: String?
    let requestId: String?
    
    enum CodingKeys: String, CodingKey {
        case result
        case error
        case requestId = "request_id"
    }
}
