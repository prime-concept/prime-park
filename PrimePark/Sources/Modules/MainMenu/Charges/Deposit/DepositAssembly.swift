//
//  DepositAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.06.2021.
//

import Foundation


final class DepositAssembly: Assembly {
    
    var toPay: String?
    
    init(toPay: String? = nil) {
        self.toPay = toPay
    }
    
    func make() -> UIViewController {
        let controller = DepositController()
        controller.lastSum = toPay
        let presenter = DepositPresenter()
        controller.presenter = presenter
        presenter.controller = controller
        return controller
    }
}
