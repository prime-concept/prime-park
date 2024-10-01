//
//  WiFiAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.03.2021.
//

import Foundation

final class WiFiAssembly: Assembly {
    func make() -> UIViewController {
        let controller = WiFiController()
        let presenter = WiFiPresenter(service: .wifi)
        controller.presenter = presenter
        presenter.controller = controller
        return controller
    }
}
