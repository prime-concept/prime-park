import Foundation
import Alamofire

final class PassEndpoint: PrimeParkEndpoint {
    private static let myIssuesListEndpoint         = "/primepark/visitor/requests/my"
    private static let forMeIssuesListEndpoint      = "/primepark/visitor/requests/forMe"
    private static let myPassesListEndpoint         = "/primepark/visitor/controls/my"
    private static let forMePassesListEndpoint      = "/primepark/visitor/controls/forMe"
    private static let createOneTimePassEndpoint    = "/primepark/visitor/standard/"
    private static let createTemporalPassEndpoint   = "/primepark/visitor/temporal/"
    private static let createPermanentPassEndpoint  = "/primepark/visitor/permanent/" //{roomId}"
    private static let revokeOtherPassEndpoint      = "/primepark/visitor/" //{visitId}
    //"Сдача пропуска и простановка отметки о выходе (для пропусков созданных текущим пользователем) 🔒" delete
    private static let revokeOneTimePassEndpoint = "/primepark/visitor/request/" //{requestId}
    //"Отзыв заявки, гостевой (только для Разовых заявок созданных текущим пользователем). Для ПП и ВП не сработает! 🔒" delete

    func getMyIssuesList(token: String, pageNumber: Int? = nil, isActive: Bool) -> EndpointResponse<IssuePass> {
        print(token)
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["is_active"] = isActive
        if let number = pageNumber {
            params["page"] = number
            params["page_size"] = 20
        }
        return self.retrieve(endpoint: Self.myIssuesListEndpoint, parameters: params, headers: headers)
    }

    func getForMeIssuesList(token: String, pageNumber: Int? = nil, isActive: Bool) -> EndpointResponse<IssuePass> {
        print(token)
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["is_active"] = isActive
        if let number = pageNumber {
            params["page"] = number
            params["page_size"] = 20
        }
        return self.retrieve(endpoint: Self.forMeIssuesListEndpoint, parameters: params, headers: headers)
    }

    /*
    func getMyPassesList(token: String, pageNumber: Int? = nil) -> EndpointResponse<Pass> {
        print(token)
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        if let number = pageNumber {
            params["page"] = number
            params["page_size"] = 20
        }
        return self.retrieve(endpoint: Self.myPassesListEndpoint, parameters: params, headers: headers)
    }

    func getForMePassesList(token: String, pageNumber: Int? = nil) -> EndpointResponse<Pass> {
        print(token)
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        if let number = pageNumber {
            params["page"] = number
            params["page_size"] = 20
        }
        return self.retrieve(endpoint: Self.forMePassesListEndpoint, parameters: params, headers: headers)
    }
    */
    
    //swiftlint:disable function_parameter_count
    func createOneTimePass(
        room: String,
        token: String,
        name: String,
        surname: String,
        secondName: String?,
        phone: String,
        dateFrom: String,
        dateTo: String,
        role: String,
        isService: Bool
    ) -> EndpointResponse<IssueResponse> {
        let endpoint = Self.createOneTimePassEndpoint + room

        var params: [String: Any] = [:]
        params["name"] = name
        params["surname"] = surname
        params["second_name"] = secondName
        params["phone_number"] = phone
        params["role"] = role
        params["is_service"] = isService
        params["date_from"] = dateFrom
        params["date_to"] = dateTo

        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.create(endpoint: endpoint, parameters: params, headers: headers, encoding: JSONEncoding.default)
    }

    // swiftlint:disable function_parameter_count
    func createTemporalPass(
        room: String,
        token: String,
        name: String,
        surname: String,
        secondName: String?,
        phone: String,
        dateFrom: String,
        dateTo: String,
        role: String,
        isService: Bool,
        verified: Bool = true
    ) -> EndpointResponse<IssueResponse> {
        let endpoint = Self.createTemporalPassEndpoint + room

        var params: [String: Any] = [:]
        params["name"] = name
        params["surname"] = surname
        params["second_name"] = secondName
        params["phone_number"] = phone
        params["role"] = role
        params["is_service"] = isService
        params["verified"] = verified
        params["date_from"] = dateFrom
        params["date_to"] = dateTo
        params["time_from"] = "00:00"
        params["time_to"] = "23:59"

        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.create(endpoint: endpoint, parameters: params, headers: headers, encoding: JSONEncoding.default)
    }

    func createPermanentPass(
        room: String,
        token: String,
        name: String,
        surname: String,
        secondName: String?,
        phone: String,
        role: String,
        verified: Bool = true
    ) -> EndpointResponse<IssueResponse> {
        let endpoint = Self.createPermanentPassEndpoint + room

        var params: [String: Any] = [:]
        params["name"] = name
        params["surname"] = surname
        params["second_name"] = secondName
        params["phone_number"] = phone
        params["role"] = role
        params["verified"] = verified

        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.create(endpoint: endpoint, parameters: params, headers: headers, encoding: JSONEncoding.default)
    }

    func revokeOtherPass(id: String, token: String) -> EndpointResponse<EmptyResponse> {
        let endpoint = Self.revokeOtherPassEndpoint + id

        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.remove(endpoint: endpoint, parameters: nil, headers: headers, encoding: JSONEncoding.default)
    }

    func revokeOneTimePass(id: String, token: String) -> EndpointResponse<EmptyResponse> {
        let endpoint = Self.revokeOneTimePassEndpoint + id

        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.remove(endpoint: endpoint, parameters: nil, headers: headers, encoding: JSONEncoding.default)
    }
}
