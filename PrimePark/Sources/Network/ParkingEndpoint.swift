import Foundation
import Alamofire

final class ParkingEndpoint: PrimeParkEndpoint {
    private static let parkingListEndpoint = "/primepark/rps/barcode/"
    private static let companyInfoEndpoint = "/primepark/rps/company/" //{companyName}

    func getParkingList(token: String) -> EndpointResponse<[Parking]> {
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: Self.parkingListEndpoint, parameters: nil, headers: headers)
    }

    // swiftlint:disable function_parameter_count
    func createOneTimeParkingIssue(
        companyID: String,
        barcodeModel: String,
        room: Int,
        carNumber: String,
        carModel: String?,
        guestName: String,
        guestPhone: String,
        date: String,
        token: String
    ) -> EndpointResponse<EmptyResponse> {
        var params: [String: Any] = [:]
        
        params["barcode_model"] = barcodeModel
        params["company_id"] = companyID
        params["room"] = room
        params["guest_plate_number"] = carNumber
        if let carModel = carModel {
            params["guest_car_model"] = carModel
        }
        params["guest_name"] = guestName
        params["guest_phone_number"] = guestPhone
        params["usage_time"] = date

        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.create(endpoint: Self.parkingListEndpoint, parameters: params, headers: headers, encoding: JSONEncoding.default)
    }

    func getBarcodeModel(companyName: String, token: String) -> EndpointResponse<Barcode> {
//        #warning("На проде исправить на реальное companyName")

		let endpoint: String = Config.resolve(
			prod: "\(Self.companyInfoEndpoint)\(companyName)",
			stage: Self.companyInfoEndpoint + ("РПС".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
		)

        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.retrieve(endpoint: endpoint, parameters: nil, headers: headers)
    }
}
