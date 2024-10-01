//
//  NetworkService.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 27.05.2021.
//
// swiftlint:disable colon

import PromiseKit
import Alamofire

protocol NetworkServiceProtocol {
	func request<T: Decodable>(
		withGroup group: DispatchGroup?,
		isRefreshing: Bool,
		accessToken: String,
		requestCompletion: @escaping (_ accessToken: String) -> EndpointResponse<T>,
		doneCompletion: ((T) -> Void)?,
		errorCompletion: ((Error) -> Void)?
	)
	
	func refreshToken(
		_ refreshToken: String?,
		_ username: String?,
		callback: ((_ accessToken: String) -> Void)?
	)
}

protocol DispatchNetworkServiceProtocol {
	func enterGroup()
	func leaveGroup()
	
	var dispatchGroup: DispatchGroup { get }
	var notifier: (() -> Void)? { get set }
}

extension DispatchNetworkServiceProtocol {
	func enterGroup() {
		dispatchGroup.enter()
	}
	
	func leaveGroup() {
		dispatchGroup.leave()
	}
	
	func setupNotifier() {
		dispatchGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
			notifier?()
		}
	}
}

final class NetworkService: NetworkServiceProtocol {
	
	private let endpoint = PrimeParkEndpoint()
	private let authService = LocalAuthService.shared
	
	static let workingQueue = DispatchQueue.global(qos: .userInitiated)
	
	func request<T>(
		withGroup group: DispatchGroup? = nil,
		isRefreshing: Bool = true,
		accessToken: String,
		requestCompletion: @escaping (_ accessToken: String) -> EndpointResponse<T>,
		doneCompletion: ((T) -> Void)? = nil,
		errorCompletion: ((Error) -> Void)? = nil
	) where T : Decodable {
		
		Self.workingQueue.promise(withGroup: group) {
			requestCompletion(accessToken).result
		}.done { content in
			print("NetworkService: done")
			doneCompletion?(content)
		}.catch { error in
			switch error {
			case PrimeParkError.invalidToken:
				guard
					isRefreshing,
					let refreshToken = self.authService.token?.refreshToken,
					let username = self.authService.user?.username
				else { return }
				print("NetworkService: INVALID TOKEN!!!")
				self.refreshToken(refreshToken, username) { accessToken in
					self.request(
						isRefreshing: false,
						accessToken: accessToken,
						requestCompletion: requestCompletion,
						doneCompletion: doneCompletion,
						errorCompletion: errorCompletion
					)
				}
			default:
				print("NetworkService: default")
				errorCompletion?(error)
			}
		}
	}
	
	func refreshToken(
		_ refreshToken: String?,
		_ username: String?,
		callback: ((_ accessToken: String) -> Void)? = nil
	) {
		guard let refreshToken = refreshToken,
			  let username = username
		else { return }
		DispatchQueue.global(qos: .userInitiated).promise {
			self.endpoint.refreshToken(refreshToken, username: username).result
		}.done { token in
			print("NetworkService: CALLBACK AFTER REFRESH TOKEN: \(token.accessToken)")
			
			self.authService.updateToken(accessToken: token)
			callback?(token.accessToken)
		}.catch { error in
			print("NetworkService: REFRESH TOKEN ERROR DESCRIPTION:", error.localizedDescription)
			
			LocalAuthService.shared.deleteUser()
			self.routeToMain()
		}
	}
}

extension NetworkService: MainScreenRouterProtocol {}
