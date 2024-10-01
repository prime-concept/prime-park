//
//  ValetTimePickerAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 06.05.2021.
//

import Foundation

protocol ValetTimeHolder: AnyObject {
    var choosenTime: Date { get set }
}

final class ValetTimePickerAssembly: Assembly {
    var presenterController: ValetTimeHolder?
    
    init(presenter: ValetTimeHolder) {
        presenterController = presenter
    }
    
    func make() -> UIViewController {
        let controller = ValetTimePickerController()
        controller.presenterController = presenterController
        return controller
    }
}
