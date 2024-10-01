//
//  ValetModalAbonementAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.05.2021.
//

import Foundation

final class ValetModalAbonementAssembly: Assembly {
    func make() -> UIViewController {
        let presenter = ValetModalAbonementPresenter()
        let controller = ValetModalAbonementController(presenter: presenter)
        controller.presenter = presenter
        presenter.controller = controller
        return controller
    }
}
