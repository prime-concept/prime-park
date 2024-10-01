//
//  ParametersAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 31.05.2021.
//

import Foundation

final class ParametersAssembly: Assembly {
    
    var content: [ParametersData]
    var selectedRow: Int
    
    init(
        content: [ParametersData],
        selectedRow: Int = 0
    ) {
        self.content = content
        self.selectedRow = selectedRow
    }
    
    func make() -> UIViewController {
        let presenter = ParametersPresenter()
        let controller = ParametersController(
            presenter: presenter,
            content: content,
            selectedRow: selectedRow
        )
        presenter.controller = controller
        return controller
    }
}

extension ParametersAssembly {
    var makeAsInheritor: ParametersController {
        return make() as! ParametersController
    }
}
