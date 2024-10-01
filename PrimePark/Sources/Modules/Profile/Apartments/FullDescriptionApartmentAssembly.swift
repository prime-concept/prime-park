//
//  ApartmentsAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 22.01.2021.
//

import Foundation

class FullDescriptionApartmentAssembly: Assembly {
    private let user: User?
    private let currentRoom: Room?
    
    init(_ user: User?, currentRoom: Room?) {
        self.user = user
        self.currentRoom = currentRoom
    }
    
    func make() -> UIViewController {
        let presenter = FullDescriptionApartmentPresenter(user)
        let controller = FullDescriptionApartmentViewController(presenter: presenter, user: user, currentRoom: currentRoom)
        presenter.controller = controller
        return controller
    }
}
