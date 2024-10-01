//
//  ChargesAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 15.03.2021.
//

import Foundation

final class ChargesAssembly: Assembly {
    func make() -> UIViewController {
        let controller = ChargesController()
        let presenter = ChargesPresenter()
        presenter.controller = controller
        controller.presenter = presenter
        return controller
    }
}
