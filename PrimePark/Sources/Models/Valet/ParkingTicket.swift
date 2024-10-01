//swiftlint:disable trailing_whitespace
import Foundation

final class ParkingTicket: Decodable {
    let ticket: String
    var pin: Int
    let title: String
    let ticketId: String
    let cardType: CardType
    let createdAt: String
    
    var vehicleDetails: VehicleDetails?
    
    let results: [ParkingTicket]
    
    enum CodingKeys: String, CodingKey {
        case title
        case ticket = "tn"
        case pin
        case createdAt
        case cardType = "type"
        case ticketId
        case vehicleDetails
        
        case results
    }
    
    convenience init(cardType: CardType) {
        self.init(ticket: "", pin: 0, cardType: cardType, ticketId: "")
    }
    
    init(ticket: String, pin: Int, cardType: CardType, ticketId: String) {
        
        self.ticket = ticket
        self.pin = pin
        
        self.cardType = cardType
        self.ticketId = ticketId
        
        self.title = ""
        self.createdAt = ""
        self.results = []
    }
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        results = (try? container?.decode([ParkingTicket].self, forKey: .results)) ?? []
        
        ticket = (try? container?.decode(String.self, forKey: .ticket)) ?? ""
        self.pin = 0
        
        if let pinStr = (try? container?.decode(String.self, forKey: .pin)),
           let pin = Int(pinStr) {
            self.pin = pin
        }
        
        title = (try? container?.decode(String.self, forKey: .title)) ?? ""
        createdAt = (try? container?.decode(String.self, forKey: .createdAt)) ?? ""
        let cardTypeStr = (try? container?.decode(String.self, forKey: .cardType)) ?? ""
        cardType = CardType(rawValue: cardTypeStr) ?? .ticket
        ticketId = (try? container?.decode(String.self, forKey: .ticketId)) ?? ""
        vehicleDetails = (try? container?.decode(VehicleDetails.self, forKey: .vehicleDetails))
    }
    
    enum CardType: String {
        case ticket = "TICKET"
        case subscription = "SUBSCRIPTION"
        case all = ""
    }
}

extension ParkingTicket {
    var isGuestCard: Bool {
        cardType == .ticket ? true : false
    }
    
    var ticketPrefix: String {
        cardType == .ticket ? "PP" : "PPR"
    }
}

extension ParkingTicket {
    
    var requestFormat: (ticket: String, pin: Int) {
        let formattedTicket = ticket.replacingOccurrences(of: #"\D"#, with: "", options: .regularExpression)
        return (ticketPrefix + formattedTicket, pin)
    }
    
    var visualFormat: (ticket: String, pin: String) {
        let formattedTicket = ticket.replacingOccurrences(of: #"\D"#, with: "", options: .regularExpression)
        return (formattedTicket, pin == 0 ? "" : "\(pin)")
    }
}
