//
//  ChannelsEndpoint.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 28.04.2021.
//

import Foundation

final class ChannelsEndpoint: PrimeParkEndpoint {
    private static let subscriptionListEndpoint = "/subscriptions/"
    
    func getChannels(token: String) -> EndpointResponse<Channel> {
        let endpoint = Self.subscriptionListEndpoint
        let headers = [
            "X-Access-Token": "\(token)",
            "Content-Type": "application/json"
        ]
        var params: [String: Any] = [:]
        params["unreadOnly"] = true
        return self.retrieve(endpoint: endpoint, parameters: params, headers: headers)
    }
    
    override init(basePath: String = Config.chatBaseURL.absoluteString) {
        super.init(basePath: basePath)
    }
}
