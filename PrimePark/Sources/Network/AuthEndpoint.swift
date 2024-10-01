import Foundation

final class AuthEndpoint: PrimeParkEndpoint {
    private static let registerEndpoint = "/mobile/register"
    private static let verifyEndpoint = "/mobile/verify"
    private static let fetchOauthToken = "/oauth/token"
    private static let getXMLFileEndpoint = "/primepark/esmart"

    func register(phone: String) -> EndpointResponse<EmptyResponse> {
        var params = self.paramsWithCredentials
        params["phone"] = phone

        let currentParamString = "\(self.paramsString)\(phone)"

        params = self.update(params: params, with: currentParamString)

        return self.create(endpoint: Self.registerEndpoint, parameters: params)
    }

    func verify(phone: String, key: String) -> EndpointResponse<User> {
        var params = self.paramsWithCredentials
        params["phone"] = phone
        params["key"] = key

        let currentParamString = "\(self.paramsString)\(phone)\(key)"

        params = self.update(params: params, with: currentParamString)

        return self.create(endpoint: Self.verifyEndpoint, parameters: params)
    }

    func fetchOauthToken(username: String, code: String) -> EndpointResponse<AccessToken> {
        let params = ["username": username, "password": code, "grant_type": "password", "scope": "private"]
        return self.create(endpoint: Self.fetchOauthToken, parameters: params, headers: self.authHeaders)
    }

    /*func refreshOauthToken(with refreshToken: String) -> EndpointResponse<AccessToken> {
        let params = ["grant_type": "refresh_token", "refresh_token": refreshToken]
        return self.create(endpoint: Self.fetchOauthToken, parameters: params, headers: self.authHeaders)
    }*/

    func getXMLFile(with token: String) -> EndpointResponse<[BLEConfig]> {
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return self.retrieve(endpoint: Self.getXMLFileEndpoint, parameters: nil, headers: headers)
    }
}

class EmptyResponse: Decodable {
}
