//
//  ValetModalAbonementPresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.05.2021.
//

import Foundation

protocol ValetModalAbonementPresenterProtocol {
    func makeOrderRequest(tariff: ValetAbonementTariff)
}

final class ValetModalAbonementPresenter: ValetModalAbonementPresenterProtocol {
    weak var controller: ValetModalAbonementControllerProtocol?
    
    private let networkService = NetworkService()
    private let endpoint = IssuesEndpoint()
    
    func makeOrderRequest(tariff: ValetAbonementTariff) {
        print(tariff)
        let descriptionText = "Private Valet Parking, создание на \(localizedWith(tariff.rawValue))"//createServiceDescription(descriptionText: descriptionText)
        
        guard
            let type = IssuesTypeService.shared.getSomeType(.creationPrivateValetParking),
            let room = LocalAuthService.shared.apartment,
            let token = LocalAuthService.shared.token?.accessToken
        else { return }
        
        controller?.startLoading()
        
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createIssue(
                    room: room.id,
                    text: descriptionText,
                    type: type,
                    token: accessToken
                )
            },
            doneCompletion: { _ in
                self.controller?.successOrder()
            },
            errorCompletion: { error in
                self.controller?.failureOrder()
                print("ERROR WHILE CALL CLEANING: \(error.localizedDescription)")
            }
        )
    }
}
