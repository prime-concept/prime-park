//
//  CounterPresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 16.03.2021.
//
//swiftlint:disable trailing_whitespace
import Foundation

protocol CounterPresenterProtocol {
    func getCountersHistory()
}

final class CounterPresenter: CounterPresenterProtocol {
    weak var controller: CounterControllerProtocol?
    
    private let authService: LocalAuthService = .shared
    private let endpoint: ChargesEndpoint = .init()
    private let networkService = NetworkService()
    
    private let counterDescription: String
    
    init(description: String) {
        counterDescription = description
    }
    
    func getCountersHistory() {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
			requestCompletion: { accessToken in
				self.endpoint.getCountersHistory(room: "\(self.authService.apartment?.id ?? 0)", token: accessToken)
			},
            doneCompletion: { counters in
                guard let special = counters.makeGrouped { $0.description }[self.counterDescription] else { return }
                self.controller?.setCountersHistory(history: special)
            },
            errorCompletion: { error in
                print("ERROR WHILE REQUESTING COUNTERS: \(error.localizedDescription)")
            }
        )
    }
}
