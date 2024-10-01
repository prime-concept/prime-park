//
//  Date+Operator.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 09.05.2021.
//
// swiftlint:disable force_unwrapping shorthand_operator
import Foundation

enum DateKind {
    case second(Int)
    case minute(Int)
    case hour(Int)
    case day(Int)
}

extension DateKind {
    static func + (rhs: Date, lhs: DateKind) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = NSTimeZone(name: "UTC")! as TimeZone
        var components = calendar.dateComponents(in: timeZone, from: rhs)
        //components.second = 60
        switch lhs {
        case .day(let days):
            if let rhsDays = components.day {
                components.day = rhsDays + days
                break
            }
            components.day = days
        case .hour(let hours):
            if let rhsHours = components.hour {
                components.hour = rhsHours + hours
                break
            }
            components.hour = hours
        case .minute(let minutes):
            if let rhsMiuntes = components.minute {
                components.minute = rhsMiuntes + minutes
                break
            }
            components.minute = minutes
        case .second(let seconds):
            if let rhsSeconds = components.second {
                components.second = rhsSeconds + seconds
                break
            }
            components.second = seconds
        }
        return calendar.date(from: components) ?? Date().dateWithCurrentTimeZone()
    }

    static func += (lhs: inout Date, rhs: DateKind) {
        lhs = lhs + rhs
    }
}

extension Date {    
    func advancedToNextHour() -> Date? {
        var date = self
        date += TimeInterval(59 * 60 + 59)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second, .minute], from: date)
        guard let minutes = components.minute,
              let seconds = components.second else {
            return nil
        }
        return date.dateWithCurrentTimeZone() - TimeInterval(minutes) * 60 - TimeInterval(seconds)
    }
    
    static func > (rhs: Date, lhs: Date) -> Bool {
        let right = [rhs.get(.year), rhs.get(.month), rhs.get(.day), rhs.get(.hour)]
        let left = [lhs.get(.year), lhs.get(.month), lhs.get(.day), lhs.get(.hour)]
        
        var counter = 0
        
        while counter < right.count && right[counter] >= left[counter] {
            
            print("right: \(right[counter]) > left: \(left[counter])")
            if right[counter] > left[counter] {
                return true
            }
            
            counter += 1
        }
        
        return false
    }
    
    func get(_ component: Calendar.Component) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        //calendar.timeZone = NSTimeZone(name: "GMT")! as TimeZone
        //calendar.timeZone = .current
        return calendar.component(component, from: self)
    }
    
    func concutedValues() -> Int {
        guard let result = Int("\(get(.year))\(get(.month))\(get(.day))\(get(.hour))") else { return 0 }
        return result
    }
    
    func set(_ component: Calendar.Component, value: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = NSTimeZone(name: "UTC")! as TimeZone
        var components = calendar.dateComponents(in: timeZone, from: self)
        switch component {
        case .day:
            components.day = value
        case .hour:
            components.hour = value
        case .minute:
            components.minute = value
        case .second:
            components.second = value
        default:
            break
        }
        return calendar.date(from: components) ?? Date().dateWithCurrentTimeZone()
    }
}
