//
//  WSService.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 28.04.2021.
//

import Foundation
import Starscream

//swiftlint:disable trailing_whitespace
class WSService {
    
    typealias QueryParams = [String: String]
    typealias Headers = [String: String]
    
    private var request: URLRequest?
    private var socket: WebSocket?
    
    private var endpoint: String
    weak var delegate: WebSocketDelegate? {
        didSet {
            socket?.delegate = delegate
        }
    }
    
    var onConnect: (() -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    
    init?(
        endpoint: String = "wss://chat.primeconcept.co.uk/chat-server/v3/messages",
        params: QueryParams,
        headers: Headers? = nil,
        timeout: Double = 20.0
    ) {
        self.endpoint = endpoint
        guard let request = formRequest(
            params: params,
            headers: headers,
            timeout: timeout
        ) else { return nil }
        self.request = request
        socket = WebSocket(request: request)
        setupSocket()
    }
    
    func connectSocket() {
        socket?.connect()
    }
    
    func disconnectSocket(
        forceTimeout: TimeInterval? = nil,
        closeCode: CloseCode
    ) {
        socket?.disconnect(
            forceTimeout: forceTimeout,
            closeCode: closeCode.rawValue
        )
    }
    
    func reload(params: QueryParams) {
        disconnectSocket(closeCode: .noStatusReceived)
        request = formRequest(params: params, headers: nil)
        guard let request = request else { return }
        socket?.request = request
        socket?.connect()
    }
    
    var isConnected: Bool {
        return socket?.isConnected ?? false
    }
    
    private func setupSocket() {
        socket?.onConnect = { [weak self] in
            self?.onConnect?()
        }
        
        socket?.onDisconnect = { [weak self] error in
            print("ws client: disconnected, error = \(error.debugDescription)")
            self?.onDisconnect?(error)
        }
    }
    
    // MARK: - Private
    
    private func formRequest(
        params: QueryParams?,
        headers: Headers?,
        timeout: Double = 5.0
    ) -> URLRequest? {
        guard var urlComponents = URLComponents(string: endpoint) else { return nil }
        
        var queryParams: [URLQueryItem] = []
        for one in (params ?? [:]) {
            queryParams.append(URLQueryItem(name: one.key, value: one.value))
        }
        urlComponents.queryItems = queryParams
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        for one in (headers ?? [:]) {
            request.setValue(one.value, forHTTPHeaderField: one.key)
        }
        print("socket request: \(request.url?.absoluteString)")
        return request
    }
}
