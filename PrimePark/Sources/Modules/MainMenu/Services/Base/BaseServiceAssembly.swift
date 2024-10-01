//
//  BaseServiceAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.03.2021.
//

import Foundation

final class BaseServiceAssembly: Assembly {
    var service: Service.ServiceType
    
    init(service: Service.ServiceType) {
        self.service = service
    }
    
    func make() -> UIViewController {
        let base = BaseServiceController(service: service)
        let presenter = BaseServicePresenter(service: service)
        base.presenter = presenter
        presenter.controller = base
        return base
    }
}
