//  ApartmentsPresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 22.01.2021.
//

import Foundation

protocol FullDescriptionApartmentPresenterProtocol {
    func showApartments()
}

class FullDescriptionApartmentPresenter: FullDescriptionApartmentPresenterProtocol {
    weak var controller: FullDescriptionApartmentControllerProtocol?
    private let user: User?
    init(_ user: User?) {
        self.user = user
    }
    func showApartments() {
    }
}
