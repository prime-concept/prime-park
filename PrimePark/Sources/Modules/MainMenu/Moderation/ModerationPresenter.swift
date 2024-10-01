//
//  ModerationPresenter.swift
//  PrimePark
//
//  Created by Ксения Салфетникова on 20.11.2020.
//

import Foundation

protocol ModerationPresenerProtocol {
    func callToMC()
}

final class ModerationPresenter: ModerationPresenerProtocol {
    private let mcPhoneNumber = "+74954812524"
    
    func callToMC() {
        if let phone = URL(string: "tel://\(mcPhoneNumber)"),
            UIApplication.shared.canOpenURL(phone) {
            UIApplication.shared.open(phone)
        }
    }
}

extension ModerationPresenter: PassPresenterProtocol {
    func revokePass() {}
}
