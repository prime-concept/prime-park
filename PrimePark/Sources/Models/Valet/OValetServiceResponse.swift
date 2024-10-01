//
//  OValetServiceResponse.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.05.2021.
//
//swiftlint:disable trailing_whitespace
import Foundation

final class OValetServiceResponse: Decodable {
    let result: String?
    let error: String?
    let requestId: String?
    
    enum CodingKeys: String, CodingKey {
        case result
        case error
        case requestId = "request_id"
    }
}
