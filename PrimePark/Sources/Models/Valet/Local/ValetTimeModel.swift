//
//  ValetTimeModel.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//
// swiftlint:disable trailing_whitespace force_unwrapping
import Foundation

final class ValetTimeModel {
    var dayOfWeek: String
    var day: String
    var month: String
    var isRunOut: Bool = false
    
    var date: Date
    
    init(date: Date) {
        self.date = date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "EEE"
        dayOfWeek = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "dd"
        day = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMM"
        month = dateFormatter.string(from: date)
        
        let currentDate = Date().dateWithCurrentTimeZone()
        
        if date > currentDate + .day(-1) {
            isRunOut = false
        } else {
            isRunOut = true
        }
    }
}

extension ValetTimeModel {
    var diffInDays: Int {
        let currentDate = Date()
        return date.get(.day) - currentDate.get(.day)
    }
}

extension ValetTimeModel: CustomStringConvertible {
    var description: String {
        return "week: \(dayOfWeek), day: \(day), month: \(month), isRunOut: \(isRunOut)" 
    }
}


