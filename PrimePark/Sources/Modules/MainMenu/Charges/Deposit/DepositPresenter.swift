//
//  DepositPresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.06.2021.
//
// swiftlint:disable trailing_whitespace
import Foundation

protocol DepositPresenterProtocol {
    func makeDepositFor(sum: String?)
    func checkDeposit(orderId: String?)
}

final class DepositPresenter: DepositPresenterProtocol {
    
    weak var controller: DepositControllerProtocol?
    
    private let authService: LocalAuthService = .shared
    private let endpoint: ChargesEndpoint = .init()
    private let networkService = NetworkService()
    
    func makeDepositFor(sum: String?) {
        guard let currentRoomId = authService.apartment?.id,
              let token = authService.token?.accessToken,
              let correctSum = Double(sum?.replacingOccurrences(of: ",", with: ".") ?? "0")
        else { return }
        controller?.startLoadingAnimation()
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.depositAccount(
                    room: currentRoomId,
                    amount: correctSum * 100,
                    token: accessToken,
                    returnURL: "https://primepark.ru/"
                )
            },
            doneCompletion: { response in
                self.controller?.endLoadingAnimation()
                self.controller?.orderId = response.order.id
                guard let paymentUrl = response.payment.paymentUrl else { return }
                self.controller?.pushWeb(link: paymentUrl)
            },
            errorCompletion: { _ in
                print("error")
            }
        )
    }
    
    func checkDeposit(orderId: String?) {
        guard
            let token = authService.token?.accessToken,
            let clearOrderId = orderId
        else { return }
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.checkDeposit(
                    orderId: clearOrderId,
                    token: accessToken
                )
            },
            doneCompletion: { response in
                self.controller?.showAlert(status: response.payment.status ?? "nil status")
            },
            errorCompletion: { _ in
                print("error")
            }
        )
    }
}
