import Foundation

// swiftlint:disable all
extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    static func startOfCurrentDate() -> Date {
        let systemCalendar = Calendar.current
        let dateComponents = systemCalendar.dateComponents(
            [.calendar, .timeZone, .era, .year, .month, .day, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear],
            from: Date())
        let startOfDay = DateComponents(
            calendar: dateComponents.calendar,
            timeZone: dateComponents.timeZone,
            era: dateComponents.era,
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            hour: 0,
            minute: 0,
            second: 0,
            nanosecond: 0,
            weekday: dateComponents.weekday,
            weekdayOrdinal: dateComponents.weekdayOrdinal,
            quarter: dateComponents.quarter,
            weekOfMonth: dateComponents.weekOfMonth,
            weekOfYear: dateComponents.weekOfYear,
            yearForWeekOfYear: dateComponents.yearForWeekOfYear).date
        return startOfDay ?? Date()
    }

    func dateWithCurrentTimeZone() -> Date {
        let timezoneOffset = Double(TimeZone.current.secondsFromGMT())
        return self.addingTimeInterval(timezoneOffset)
        /*let epochDate = Date().timeIntervalSince1970
        //let timezoneEpochOffset: Double = round(epochDate) + Double(timezoneOffset)
        let timeZoneOffsetDate = Date(timeIntervalSince1970: round(epochDate) + Double(timezoneOffset))
        return timeZoneOffsetDate*/
    }
    
    var toStr: String {
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateFormat = "dd.MM.yyyy"
        utcDateFormatter.timeZone = TimeZone(identifier: "UTC")!
        let stringRep = utcDateFormatter.string(from: self)
        
        return stringRep
    }
    
    func calcDiffInMin(_ beforeDate: Date) -> Int {
        let newDateMinutes = self.timeIntervalSinceReferenceDate / 60
        let oldDateMinutes = beforeDate.timeIntervalSinceReferenceDate / 60
        return Int(newDateMinutes - oldDateMinutes)
    }
    
    func calculateDifferenceInSeconds(_ from: Date) -> Int {
        let currentSeconds = self.timeIntervalSinceReferenceDate
        let fromSeconds = from.timeIntervalSinceReferenceDate
        return Int(currentSeconds - fromSeconds)
    }

    var dayNumber: String {
        let calendar = Calendar.current
        return "\(calendar.component(.day, from: self))"
    }
    var month: String {
        return self.string("LLL")
    }
    var dayOfWeek: String {
        return self.string("EEE")
    }
    
    enum DateFormat: Int {
        case HHmm = 0
        case ddMMyyyy
    }
    
    static func createDateWith(time: String, format: DateFormat = .HHmm) -> Date {
        let dateFormatter = DateFormatter()
        switch format {
        case .HHmm:
            dateFormatter.dateFormat = "HH:mm"
        case .ddMMyyyy:
            dateFormatter.dateFormat = "dd.MM.yyyy"
        }
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: time)!
    }

    static func compareTime(firstTime: Date, secondTime: Date) -> ComparisonResult {
        let firstDateComponents = Calendar.current.dateComponents(in: TimeZone(identifier: "GMT")!, from: firstTime)
        let secondDateComponents = Calendar.current.dateComponents(in: TimeZone(identifier: "GMT")!, from: secondTime)
        if firstDateComponents.hour == secondDateComponents.hour {
            if firstDateComponents.minute == secondDateComponents.minute {
                return .orderedSame
            } else if firstDateComponents.minute ?? 0 < secondDateComponents.minute ?? 0 {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        } else if firstDateComponents.hour ?? 0 < secondDateComponents.hour ?? 0 {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }

    static func compareDays(firstDate: Date, secondDate: Date) -> ComparisonResult {
        let firstDateComponents = Calendar.current.dateComponents(in: TimeZone(identifier: "GMT")!, from: firstDate)
        let secondDateComponents = Calendar.current.dateComponents(in: TimeZone(identifier: "GMT")!, from: secondDate)
        if firstDateComponents.day == secondDateComponents.day {
            return .orderedSame
        } else if firstDateComponents.day ?? 0 < secondDateComponents.day ?? 0 {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }
}

