//
//  RequestService.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.02.2021.
//
//swiftlint:disable all

import Foundation

final class RequestService {
    typealias SuccessCompletion = (
        _ configArr: [BLEConfig],
        _ accessToken: AccessToken) -> Void
    
    private var endpoint = AuthEndpoint()
    private var authService = LocalAuthService.shared
    private let networkService = NetworkService()
    
    static var shared: RequestService = {
        return RequestService()
    }()
    
    private init() {}
    
    func downloadConfigurations(
        successCompletion: @escaping SuccessCompletion
    ) {
        guard let user = authService.user,
              let accessToken = authService.token
        else {
            fatalError("user is nil")
        }
        
        networkService.request(
			accessToken: accessToken.accessToken,
            requestCompletion: { accessToken in
                self.endpoint.getXMLFile(with: accessToken)
            },
            doneCompletion: { configArray in
                successCompletion(configArray, accessToken)
            },
            errorCompletion: { error in
                print("ERROR WHILE DOWNLOAD XML FILE: \(error.localizedDescription)")
            }
        )
    }
}
