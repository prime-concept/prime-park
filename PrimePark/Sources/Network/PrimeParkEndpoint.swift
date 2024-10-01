import CommonCrypto
import UIKit

class PrimeParkEndpoint: Endpoint {
    private static let fetchOauthToken = "/oauth/token"
    
    // Charges
    
    static let mockEndpoint = "https://mobile.primeparkmanagement.ru/static"

    var paramsWithCredentials: [String: Any] {
		["client_id": Config.clientID, "device_id": UIDevice.current.identifierForVendor?.uuidString ?? ""]
    }

    var paramsString: String {
        var result = ""
        result += self.paramsWithCredentials["client_id"] as? String ?? ""
        result += self.paramsWithCredentials["device_id"] as? String ?? ""
        return result
    }

    var authHeaders: [String: String] {
		let authString = "\(Config.clientID):\(Config.clientSecret)"
        guard let token = authString.data(using: .utf8)?.base64EncodedString() else {
            fatalError("It shouldn`t crash")
        }
        return ["Authorization": "Basic \(token)"]
        /*return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]*/
    }

	init(basePath: String = Config.endpoint) {
        super.init(basePath: basePath)
    }

    func update(params: [String: Any], with string: String) -> [String: Any] {
        var updatedParams = params
        updatedParams["signature"] = self.signature(from: string)
        return updatedParams
    }

    func refreshToken(_ token: String, username: String) -> EndpointResponse<AccessToken> {
        let params = [
            "grant_type": "refresh_token",
            "refresh_token": token,
            "scope": "private",
            "username": username
        ]
        print("USERNAME: ", username)
        return self.create(endpoint: Self.fetchOauthToken, parameters: params, headers: self.authHeaders)
    }

    func loadImage(at path: String) -> EndpointResponse<Data> {
        return self.retrieve(endpoint: path)
    }

    private func signature(from string: String) -> String? {
		let keyData = NSData(base64Encoded: Config.clientSecret, options: .ignoreUnknownCharacters)

        guard let cData = string.cString(using: .ascii) else {
            return nil
        }

        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

        CCHmac(
            CCHmacAlgorithm(kCCHmacAlgSHA256),
            keyData?.bytes,
            keyData?.length ?? 0,
            cData,
            strlen(cData),
            result
        )

        let resultData = NSData(bytes: result, length: digestLen)

        result.deallocate()

        return resultData.base64EncodedString()
    }
}
