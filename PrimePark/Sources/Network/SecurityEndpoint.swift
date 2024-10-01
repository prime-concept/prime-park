import Foundation
import Alamofire

final class SecurityEndpoint: PrimeParkEndpoint {
	private static let callInRoomSecurityEndpoint = "/primepark/security/room"
	private static let callInLobbySecurityEndpoint = "/primepark/security"

	func callInRoomSecurity(room: Int, token: String) -> EndpointResponse<EmptyResponse> {
		var params: [String: Int] = [:]
		params["room"] = room
		//params["location"] = 1
		let headers = [
			"Authorization": "Bearer \(token)",
			"Content-Type": "application/json"
		]

		return self.create(endpoint: Self.callInRoomSecurityEndpoint, parameters: params, headers: headers, encoding: JSONEncoding.default)
	}

	func callInLobbySecurity(room: Int, location: String, token: String) -> EndpointResponse<EmptyResponse> {
		var params: [String: Any] = [:]
		params["room"] = room
		params["location"] = location

		let headers = [
			"Authorization": "Bearer \(token)",
			"Content-Type": "application/json"
		]

		return self.create(endpoint: Self.callInLobbySecurityEndpoint, parameters: params, headers: headers, encoding: JSONEncoding.default)
	}
}
