//
//  String.swift
//  String
//
//  Created by Vanjo Lutik on 07.12.2021.
//

import Foundation

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension String {
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // swiftlint:disable force_unwrapping
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        
        return dateFormatter.date(from: self) ?? Date()
    }
}
