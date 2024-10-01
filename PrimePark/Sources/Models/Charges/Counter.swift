//
//  Counter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 26.03.2021.
//
//swiftlint:disable trailing_whitespace

import Foundation

final class Counter: Codable {
    enum Concrete {
        case hotWater
        case coldWater
        case electricity
        case heating
        case cooling
        
        init?(value: String) {
            switch value {
            case "HotWaterAreaMeter":
                self = .hotWater
            case "ColdWaterAreaMeter":
                self = .coldWater
            case "ElectricTwoRateAreaMeter":
                self = .electricity
            case "HeatAreaMeter":
                self = .heating
            case "RefrigerationAreaMeter":
                self = .cooling
            default:
                return nil
            }
        }
    }
    
    enum Measure: Equatable {
        case cube(Counter.Concrete? = nil)
        case tariff(Counter.Concrete? = nil)
        case gcal(Counter.Concrete? = nil)
        
        var rawValue: String {
            switch self {
            case .cube(let counter), .tariff(let counter), .gcal(let counter):
                return counter?.visualName ?? "nil value"
            }
        }
    }
    
    let id: String
    let typeStr: String
    let description: String
    let subtype: String?
    let values: Double
    let period: Date
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case typeStr = "type"
        case description
        case subtype
        case values
        case period
        case date
    }
    
    init(from decoder: Decoder) {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.typeStr = (try? container?.decode(String.self, forKey: .typeStr)) ?? ""
        self.description = (try? container?.decode(String.self, forKey: .description)) ?? ""
        self.subtype = try? container?.decode(String.self, forKey: .subtype)
        self.values = (try? container?.decode(Double.self, forKey: .values)) ?? 0
        
        let periodUnixTime = (try? container?.decode(Double.self, forKey: .period)) ?? 0
        let dateUnixTime = (try? container?.decode(Double.self, forKey: .date)) ?? 0
        
        self.period = Date(timeIntervalSince1970: periodUnixTime / 1000) // Format seconds
        self.date = Date(timeIntervalSince1970: dateUnixTime / 1000) // Format seconds
    }
    
    init(
        id: String = "fake_id",
        typeStr: String = "ElectricTwoRateAreaMeter",
        description: String = "40681327",
        subtype: String = "day",
        date: Date = Date(),
        values: Double = Double.random(in: 100...1500).rounded(),
        period: Date = Date(timeIntervalSince1970: 1010101010)
         ) {
        self.id = id
        self.typeStr = typeStr
        self.description = description
        self.subtype = subtype
        self.date = date
        self.values = values
        self.period = period
    }
}

extension Counter {
    var strMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return "\(getProperMonthName) " + dateFormatter.string(from: period)
    }
    
    var getProperMonthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = LocalAuthService.shared.getCurrentLocale()
        return dateFormatter.monthSymbols[Calendar.current.component(.month, from: period) - 1]
    }

    func separateId() -> String {
        let components = id.components(separatedBy: "_id")
        return components[0]
    }
}

extension Counter: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
    
    static func == (lhs: Counter, rhs: Counter) -> Bool {
        return lhs.description == rhs.description
    }
}

extension Counter: Comparable {
    static func < (lhs: Counter, rhs: Counter) -> Bool {
        return lhs.visualName < rhs.visualName
    }
}

extension Counter {
    
    var type: Concrete {
        Concrete(value: typeStr) ?? .cooling
    }
    
    var style: Counter.Measure {
        switch type {
        case .coldWater, .hotWater:
            return .cube(type)
        case .electricity:
            return .tariff(type)
        case .heating, .cooling:
            return .gcal(type)
        }
    }
    
    var title: String {
        switch style {
        case .cube, .gcal:
            return strMonth
        case .tariff:
            return tariff
        }
    }
    
    var valuesDisplayable: String {
        switch type {
        case .coldWater, .hotWater:
            return "\(values) m³"
        case .electricity:
            return "\(values) \(localizedWith("charges.counter.kW"))"
        case .heating, .cooling:
            return "\(values) \(localizedWith("charges.counter.Gcal"))"
        }
    }
    
    var imageName: String {
        switch type {
        case .hotWater:
            return "Water"
        case .electricity:
            return "Energy"
        case .coldWater:
            return "Water"
        case .heating:
            return "Heating"
        default:
            return "Refrigeration"
        }
    }
    
    var visualName: String {
        return type.visualName
    }
    
    private var tariff: String {
        switch subtype {
        case "day":
            return localizedWith("charges.counter.day")
        case "night":
            return localizedWith("charges.counter.night")
        default:
            return localizedWith("charges.counter.total")
        }
    }
}

extension Array where Element == Counter {
    
    //swiftlint:disable identifier_name
    func makeGrouped(by: @escaping (Counter) -> String) -> [String: [Counter]] {
        var dictionary: [String: [Counter]] = [:]
        forEach {
            let key = by($0)
            if var value = dictionary[key] {
                value.append($0)
                dictionary.updateValue(value, forKey: key)
            } else {
                dictionary.updateValue([$0], forKey: key)
            }
        }
        return dictionary
    }
    
    func makeGroupedForTariff() -> [String: [Counter]] {
        var dictionary = makeGrouped { $0.strMonth }
        dictionary.forEach {
            let monthSum = $0.value.reduce(0) { $0 + $1.values }
            let counter = Counter(subtype: "", values: monthSum)
            if var values = dictionary[$0.key] {
                values.append(counter)
                dictionary.updateValue(values, forKey: $0.key)
            }
        }
        return dictionary
    }
}

private extension Counter.Concrete {
    var visualName: String {
        switch self {
        case .hotWater:
            return "charges.counter.hotWater"
        case .coldWater:
            return "charges.counter.coldWater"
        case .electricity:
            return "charges.counter.electricity"
        case .heating:
            return "charges.counter.heating"
        case .cooling:
            return "charges.counter.cooling"
        }
    }
}
