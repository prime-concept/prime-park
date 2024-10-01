//
//  ValetEndpoint.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.05.2021.
//
//swiftlint:disable trailing_whitespace
import Alamofire

final class ValetEndpoint: PrimeParkEndpoint {

    // all cards
    private static let cardsListEndpoint                    = "/primepark/valet/cards"
    // get status
    private static let currentVehicleRequestStateEndpoint   = "/primepark/valet/getCurrentVehicleRequestState"
    private static let currentVehicleStatusEndpoint         = "/primepark/valet/getCurrentVehicleStatus"
    private static let vehicleDetailsTNumPinEndpoint        = "/primepark/valet/getVehicleDetailsTNumPin"
    private static let vehicleDetailsEndpoint               = "/primepark/valet/getVehicleDetails"
    
    private static let vehicleHistoryForTicketId            = "/primepark/valet/getVehicleHistoryForTicketId"
    
    private static let requestParametersEndpoint            = "/primepark/valet/getRequestParameters"
    
    // request
    private static let requestVehicleByTidEndpoint          = "/primepark/valet/requestVehicleByTicketId"
    
    // stop
    private static let stopVehicleRequestEndpoint           = "/primepark/valet/stopVehicleRequestByTicketId"
    
    private static let tenantStatusEndpoint                 = "/primepark/valet/getTenantStatus"
    
    
    //https://www.o-valet.com/pub-aprs/v1?a=startReqTid&tid=8177043&m=9
    
    // MARK: - Get & Post Parking Cards
    
    func getParkingCards(
        token: String,
        cardType: ParkingTicket.CardType = .ticket,
        page: Int? = nil,
        pageSize: Int? = nil
    ) -> EndpointResponse<ParkingTicket> { // PageOfParkingTickets
        let endpoint = Self.cardsListEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        if let size = pageSize {
            params["page_size"] = size
        }
        if let page = page {
            params["page"] = page
        }
        
        params["card_type"] = cardType.rawValue
        
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    /*
    func addParkingCard(
        token: String,
        ticket: String,
        pin: Int? = nil,
        title: String,
        createdAt: String? = nil
    ) -> EndpointResponse<String> {
        let endpoint = Self.cardsListEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["ticket"] = ticket
        params["title"] = title
        if let pin = pin {
            params["pin"] = pin
        }
        if let createdAt = createdAt {
            params["createdAt"] = createdAt
        }
        
        return self.create(endpoint: endpoint, parameters: params, headers: headers, encoding: JSONEncoding.default/*BodyStringEncoding(body: params)*/)
    }
    
    func deleteParkingCard(
        token: String,
        ticket: String,
        pin: Int? = nil,
        title: String,
        createdAt: String? = nil
    ) -> EndpointResponse<String> {
        let endpoint = Self.cardsListEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["ticket"] = ticket
        params["title"] = title
        if let pin = pin {
            params["pin"] = pin
        }
        if let createdAt = createdAt {
            params["createdAt"] = createdAt
        }
        
        return self.update(endpoint: endpoint, parameters: params, headers: headers)
    }
    */
    
    // MARK: - Get Vehicle Status
    
    func getCurrentVehicleStatus(
        token: String,
        ticket: String,
        pin: Int
    ) -> EndpointResponse<VehicleStatus> { // VehicleStatus
        let endpoint = Self.currentVehicleStatusEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["t"] = ticket
        params["p"] = pin
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    func getCurrentVehicleRequestState(
        token: String,
        ticket: String
    ) -> EndpointResponse<VehicleState> {
        let endpoint = Self.currentVehicleRequestStateEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["tid"] = ticket
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    func getVehicleHistory(
        token: String,
        ticketId: String
    ) -> EndpointResponse<VehicleHistory> {
        let endpoint = Self.vehicleHistoryForTicketId
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["tid"] = ticketId
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    // MARK: - Create Vehicle Request All Ways
    
    func requestVehicle(
        token: String,
        tid: String,
        minutesToRequest: Int
    ) -> EndpointResponse<OValetServiceResponse> {
        let endpoint = Self.requestVehicleByTidEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["tid"] = tid
        params["m"] = minutesToRequest
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    // MARK: - Stop Vehicle Request All Ways
    
    func stopVehicleRequest(
        token: String,
        tid: String
    ) -> EndpointResponse<OValetServiceResponse> { // OValetServiceResponse
        let endpoint = Self.stopVehicleRequestEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["tid"] = tid
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    // MARK: - Get Vehicle Details
    
    /// besides getting full details about car this method actually add card to card list (only for guest card)
    func getVehicleDetails(
        token: String,
        tn: String,
        pn: Int
    ) -> EndpointResponse<VehicleDetails> {
        let endpoint = Self.vehicleDetailsTNumPinEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["tn"] = tn
        params["pn"] = pn
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    /// tid way for abonements
    func getVehicleDetails(
        token: String,
        tid: String
    ) -> EndpointResponse<VehicleDetails> {
        let endpoint = Self.vehicleDetailsEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["tid"] = tid
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    func getRequestParameters(
        token: String,
        ticket: String,
        pin: Int
    ) -> EndpointResponse<RequestOptions> { // RequestOptions
        let endpoint = Self.requestParametersEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["t"] = ticket
        params["p"] = pin
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    func getTenantStatus(
        token: String
    ) -> EndpointResponse<TenantStatus> {
        let endpoint = Self.tenantStatusEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: endpoint, headers: headers)
    }
    
    func setParkingTitle(
        token: String,
        tn: String,
        title: String
    ) -> EndpointResponse<EmptyResponse> {
        let endpoint = Self.cardsListEndpoint + "/" + tn + "?title=\(title)"
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
//        var params: [String: Any] = [:]
//        params["title"] = title
        return self.create(endpoint: endpoint, parameters: nil, headers: headers, encoding: JSONEncoding.default)
    }
}
