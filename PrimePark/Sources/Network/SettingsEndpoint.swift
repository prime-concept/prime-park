import Foundation
import Alamofire

// swiftlint:disable trailing_whitespace
final class SettingsEndpoint: PrimeParkEndpoint {
    private static let userInfoEndpoint = "/primepark/me"
    private static let residentsListEndpoint = "/primepark/residents/" // room_id
    private static let userImgUploadEndpoint = "/primepark/upload"

    func loadUserInfo(token: String) -> EndpointResponse<User> {
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: Self.userInfoEndpoint, parameters: nil, headers: headers)
    }

    func getResidentsList(room: String, token: String) -> EndpointResponse<[Resident]> {
        let endpoint = Self.residentsListEndpoint + "\(room)"
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        return self.retrieve(endpoint: endpoint, parameters: nil, headers: headers)
    }
    
    func postProfileImg(token: String, imgData: Data) -> EndpointResponse<String> {
        let endpoint = Self.userImgUploadEndpoint
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "multipart/form-data"
        ]
        var params: [String: Any] = [:]
        let uuid = UUID().uuidString
        params["file"] = uuid
        return self.upload(endpoint: endpoint, data: imgData, parameters: params, headers: headers)
    }
    
    func changeProfileImg(token: String, imgURL: String) -> EndpointResponse<User> {
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["avatar"] = imgURL
        return self.patch(endpoint: Self.userInfoEndpoint, parameters: params, headers: headers)
    }
}
