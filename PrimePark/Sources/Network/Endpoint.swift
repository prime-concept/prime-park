import Alamofire
import Foundation
import PromiseKit

typealias CancellationToken = () -> Void
typealias EndpointResponse<T> = (result: Promise<T>, cancellation: CancellationToken)
//swiftlint:disable all
class Endpoint {
    private lazy var manager = SessionManager(configuration: self.sessionConfiguration)

    private let basePath: String

    private lazy var sessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        return configuration
    }()

    init(
        basePath: String,
        requestAdapter: RequestAdapter? = nil
    ) {
        self.basePath = basePath
        self.manager.adapter = requestAdapter
    }

    // MARK: - Common

    func request(
        endpoint: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding
    ) -> EndpointResponse<Data> {
        var isCancelled = false
        var dataRequest: DataRequest?

        let promise = Promise<Data> { seal in
            let requestBlock = {
                let path = self.makeFullPath(endpoint: endpoint)
                print("request created: path = \(path)\n\tmethod = \(method)\n\tparams = \(String(describing: parameters))\n\theaders = \(String(describing: headers))")

                dataRequest = self.manager.request(
                    path,
                    method: method,
                    parameters: parameters,
                    encoding: encoding,
                    headers: headers
                ).responseData { response in
                    if isCancelled {
                        seal.reject(PrimeParkError.requestRejected)
                        return
                    }

                    if response.response?.statusCode == 401 {
                        //let str = String(data: response.data ?? Data(), encoding: .utf8)
                        seal.reject(PrimeParkError.invalidToken)
                        
                        return
                    }

                    switch response.result {
                    case .failure(let error):
                        print("create request failed: \(error)")
                        seal.reject(error)
                    case .success(let data):
                        seal.fulfill(data)
                    }
                }
            }

            requestBlock()
        }

        let cancellation = {
            isCancelled = true
            dataRequest?.cancel()
        }

        return (promise, cancellation)
    }
    
    // MARK: - Create (POST) Upload
    
    func upload<V: Decodable>(
        endpoint: String,
        data: Data,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default
    ) -> EndpointResponse<V> {
        var isCancelled = false
        var dataRequest: DataRequest?
        
        let promise = Promise<Data> { seal in
            let requestBlock = {
                let path = self.makeFullPath(endpoint: endpoint)
//                print("request created: path = \(path)\n\tmethod = \(HTTPMethod.post)\n\tparams = \(String(describing: parameters))")
                
                self.manager.upload(
                    multipartFormData: { multipart in
                        multipart.append(
                            data,
                            withName: parameters?.first?.key ?? "file",
                            fileName: "\(parameters?.first?.value ?? "file").jpg",
                            mimeType: "image/jpg"
                        )
                }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
                to: path,
                method: .post,
                headers: headers
                ) { result in
                    switch result {
                    case .success(let upload, _, _):
                        dataRequest = upload
                        upload.responseData { response in
                            
                            if isCancelled {
                                seal.reject(PrimeParkError.requestRejected)
                                return
                            }
                            
                            if response.response?.statusCode == 401 {
                                //let str = String(data: response.data ?? Data(), encoding: .utf8)
                                seal.reject(PrimeParkError.invalidToken)
                                return
                            }
                            
                            switch response.result {
                            case .failure(let error):
                                print("create request failed: \(error)")
                                seal.reject(error)
                            case .success(let data):
                                seal.fulfill(data)
                            }
                        }
                        
                    case .failure(let encodingError):
                        print(encodingError)
                    }
                }
            }
            
            requestBlock()
        }
        
        let cancellation = {
            isCancelled = true
            dataRequest?.cancel()
        }
        
        let newPromise: Promise<V> = self.decodeData(from: promise)
        return (newPromise, cancellation)
    }

    // MARK: - Create (POST)

    func create<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .post,
            parameters: parameters,
            headers: headers,
            encoding: encoding
        )
        let newPromise: Promise<V> = self.decodeData(from: promise)
        return (newPromise, cancellation)
    }

    // MARK: - Retrieve (GET)

    func retrieve<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .get,
            parameters: parameters,
            headers: headers,
            encoding: URLEncoding.default
        )

        let newPromise: Promise<V> = self.decodeData(from: promise)
        return (newPromise, cancellation)
    }

    // MARK: - Update (PUT)

    func update<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .put,
            parameters: parameters,
            headers: headers,
            encoding: JSONEncoding.default
        )

        let newPromise: Promise<V> = self.decodeData(from: promise)
        return (newPromise, cancellation)
    }
    
    // MARK: - Update (PUT)
    
    func patch<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .patch,
            parameters: parameters,
            headers: headers,
            encoding: JSONEncoding.default
        )

        let newPromise: Promise<V> = self.decodeData(from: promise)
        return (newPromise, cancellation)
    }

    // MARK: - Remove (DELETE)

    func remove<V: Decodable>(
        endpoint: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) -> EndpointResponse<V> {
        let (promise, cancellation) = self.request(
            endpoint: endpoint,
            method: .delete,
            parameters: parameters,
            headers: headers,
            encoding: encoding
        )

        let newPromise: Promise<V> = self.decodeData(from: promise)
        return (newPromise, cancellation)
    }

    // MARK: - Private API

    private func makeFullPath(endpoint: String) -> String {
        "\(self.basePath)\(endpoint)"
    }

    private func decodeData<T: Decodable>(from promise: Promise<Data>) -> Promise<T> {
        Promise<T> { seal in
            promise.done { data in
                let decoder = JSONDecoder()

                do {
                    if data.isEmpty {
                        if let emptyResponse = EmptyResponse() as? T {
                            seal.fulfill(emptyResponse)
                        }
                    }
                    if let xmlString = String(data: data, encoding: .utf8),
                        let xmlStringCast = xmlString as? T,
                        xmlString.contains("<?xml") {
                        seal.fulfill(xmlStringCast)
                    }

                    let object = try decoder.decode(T.self, from: data)
                    print("before Prime Park response data is \(String(data: data, encoding: .utf8) ?? "")")
                    if let error = self.checkError(data) {
                        seal.reject(error)
                    }
                    seal.fulfill(object)
                } catch {
                    /*let str = String(data: data, encoding: .utf8)
                    let str2 = String(data: data, encoding: .unicode)
                    let str3 = String(data: data, encoding: .ascii)
                    let str4 = String(data: data, encoding: .utf16)
                    let str5 = String(data: data, encoding: .utf32)*/
                    print("catch Prime Park response data is \(String(data: data, encoding: .utf8) ?? "")")
//                    print("decoding data error: \(error)")
                    if let str = String(data: data, encoding: .utf8) {
                        if str.contains("phone_number") || str.contains("guest_phone_number") {
                            seal.reject(PrimeParkError.createPassPhoneError)
                        } else if str.contains("detail") && str.contains("роль") {
                            seal.reject(PrimeParkError.createPassRoleError)
                        } else if str.contains("length") {
                            seal.reject(PrimeParkError.createPassNameLengthError)
                        } else if str.contains("detail") && str.contains("VC") {
                            seal.reject(PrimeParkError.createPassTemplateError)
                        }
                    }
                    seal.reject(PrimeParkError.decodeFailed)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func checkError(_ data: Data) -> Error? {
        let decoder = JSONDecoder()
        let object = try? decoder.decode([String: String].self, from: data)
        if let errorString = object?["error"] {
            if errorString == "external_auth_failure" {/*errorString.contains("СМС") {*/
                guard let errorDescription = object?["errorDescription"] else {
                    return PrimeParkError.otherError
                }
                if errorDescription.contains("СМС") {
                    return PrimeParkError.invalidCode
                } else if errorDescription.contains("повторно") {
                    return PrimeParkError.codeIsCancelled
                } else {
                    return PrimeParkError.otherError
                }
            } else if errorString == "key_verification_constraint" {
                return PrimeParkError.maximumAttempts
            } else if errorString == "invalid_token" {
                return PrimeParkError.invalidToken
            } else if errorString == "error" {
                guard let errorDescription = object?["errorDescription"] else {
                    return PrimeParkError.otherError
                }
                if errorDescription.contains("length") {
                    return PrimeParkError.createPassNameLengthError
                }
            } else {
                return PrimeParkError.otherError
            }
        }
        return nil
    }
}

// MARK: - Enums

enum PrimeParkError: Swift.Error {
    case requestRejected
    case decodeFailed
    case invalidDateDecoding
    case serverError
    case invalidCode
    case codeIsCancelled
    case maximumAttempts
    case invalidToken
    case otherError
    case createPassPhoneError
    case createPassRoleError
    case createPassTemplateError
    case createPassNameLengthError
}

// MARK: - Structs

struct BodyStringEncoding: ParameterEncoding {

    private let body: [String: Any]

    init(body: [String: Any]) { self.body = body }

    func encode(_ urlRequest: Alamofire.URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard var urlRequest = urlRequest.urlRequest else { throw Errors.emptyURLRequest }
        
        let json = "\(body)"
            .replacingOccurrences(of: "[", with: "{")
            .replacingOccurrences(of: "]", with: "}")
        
        print(json)
        
        guard let data = json.data(using: .utf8) else { throw Errors.encodingProblem }
        urlRequest.httpBody = data
        print(data)
        return urlRequest
    }
}

extension BodyStringEncoding {
    enum Errors: Error {
        case emptyURLRequest
        case encodingProblem
    }
}

extension BodyStringEncoding.Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .emptyURLRequest: return "Empty url request"
            case .encodingProblem: return "Encoding problem"
        }
    }
}
