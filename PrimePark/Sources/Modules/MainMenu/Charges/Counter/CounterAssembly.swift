//
//  CounterAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 16.03.2021.
//

import Foundation

final class CounterAssembly: Assembly {
    private var style: Counter.Measure
    private var description: String
    
    init(
        style: Counter.Measure,
        description: String
    ) {
        self.style = style
        self.description = description
    }
    
    func make() -> UIViewController {
        let controller = CounterController(style: style)
        let presenter = CounterPresenter(description: description)
        controller.presenter = presenter
        presenter.controller = controller
        return controller
    }
}
