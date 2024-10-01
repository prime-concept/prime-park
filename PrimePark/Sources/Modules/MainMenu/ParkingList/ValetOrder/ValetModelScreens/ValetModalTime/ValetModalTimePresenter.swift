//
//  ValetModalTimePresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation

protocol ValetModalTimePresenterProtocol {
    func getContent() -> [ValetTimeModel]
    var parkingTicket: ParkingTicket { get }
}

final class ValetModalTimePresenter: ValetModalTimePresenterProtocol {
    
    weak var controller: ValetModalTimeControllerProtocol? {
        didSet {
            controller?.transitContent(content: getContent())
        }
    }
    
    let endpoint = ValetEndpoint()
    let networkService = NetworkService()
    let parkingTicket: ParkingTicket
    
    init(parkingTicket: ParkingTicket) {
        self.parkingTicket = parkingTicket
    }
    
    func getContent() -> [ValetTimeModel] {
        var result: [ValetTimeModel] = []
        let currentDay = Date().dateWithCurrentTimeZone()
        guard let startDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDay) else { return [] }
        result.append(ValetTimeModel(date: startDay))
        
        print(startDay)
        
        for i in 1..<14 {
            if let nextDay = Calendar.current.date(byAdding: .day, value: i, to: startDay) {
                print(nextDay)
                result.append(ValetTimeModel(date: nextDay))
            }
        }
        return result
    }
}

extension Date {
    static func formDiffDate(date: Date, time: Date) -> TimeInterval {
        let calendar = Calendar(identifier: .gregorian)
        let current = Date().dateWithCurrentTimeZone()
        
        // swiftlint:disable force_unwrapping
        let year = date.get(.year)
        let month = date.get(.month)
        let days = date.get(.day)
        let hours = time.get(.hour)
        let minutes = time.get(.minute)
        
        let components = DateComponents(year: year, month: month, day: days, hour: hours, minute: minutes)
        //components.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        let choosenDate = calendar.date(from: components)!
        
        let diff = choosenDate.timeIntervalSince(current)
        
        let fullSeconds = diff + (60 - TimeInterval(Int(diff) % 60))
        
        return fullSeconds
    }
}

extension TimeInterval {
    func toMinutes() -> Int { Int(self / 60) }
}
