//
//  GSMAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.03.2021.
//

import Foundation

final class GSMAssembly: Assembly {
    func make() -> UIViewController {
        let controller = GSMController(service: .gsm)
        let presenter = BaseServicePresenter(service: .gsm)
        controller.presenter = presenter
        presenter.controller = controller
        return controller
    }
}
