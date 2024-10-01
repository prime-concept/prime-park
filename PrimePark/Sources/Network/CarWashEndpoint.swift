import Foundation
import Alamofire

final class CarWashEndpoint: PrimeParkEndpoint {
    private static let carWashHistoryEndpoint = "/clients/visits/search"
    private static let carWashTimeslotsEndpoint = "/book_times/"
    private static let carWashServicesEndpoint = "/company/services"
    private static let carWashRecordEndpoint = "/records"

    override init(basePath: String = Config.carWashURL.absoluteString) {
        super.init(basePath: basePath)
    }

    func getFilteredHistory(token: String, phone: String) -> EndpointResponse<CarWashHistory>  {
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "text/plain"
        ]
        let parameters: [String: Any] = [
            "client_phone": phone
        ]
        return self.create(endpoint: Self.carWashHistoryEndpoint, parameters: parameters, headers: headers, encoding: JSONEncoding.default)
    }

    func getTimeslots(token: String, date: String) -> EndpointResponse<Timeslots> {
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        return self.retrieve(endpoint: Self.carWashTimeslotsEndpoint + date, headers: headers)
    }

    func getServices(token: String) -> EndpointResponse<CarWashServices> {
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        return self.retrieve(endpoint: Self.carWashServicesEndpoint, headers: headers)
    }

    func createCarWashRequest(token: String, comment: String, timeslot: Timeslot, service: ServicesViewModel, user: User) -> EndpointResponse<CreateRecordResponse> {
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        let parameters: [String: Any] = [
            "staff_id": service.staffId,
            "services": [
                ["id": service.id]
            ],
            "client": [
                "phone": user.phone,
                "name": user.getFullName()
            ],
            "datetime": timeslot.datetime,
            "seance_length": timeslot.seanceLength,
            "send_sms": true,
            "comment": comment
        ]

        return self.create(endpoint: Self.carWashRecordEndpoint, parameters: parameters, headers: headers, encoding: JSONEncoding.default)
    }
}
