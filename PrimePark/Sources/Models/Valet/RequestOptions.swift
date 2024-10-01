//
//  RequestOptions.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.05.2021.
//
//swiftlint:disable trailing_whitespace
import Foundation

final class RequestOptions: Decodable {
    let currentDriverAssigned: Driver
    let minRequestTime: Int
    let maxRequestTime: Int
    let incrementMinutes: Int
    let balanceDue: Double
    
    enum CodingKeys: String, CodingKey {
        case currentDriverAssigned = "current_driver_assigned"
        case minRequestTime = "min_request_time"
        case maxRequestTime = "max_request_time"
        case incrementMinutes = "increment_minutes"
        case balanceDue = "balance_due"
    }
}
