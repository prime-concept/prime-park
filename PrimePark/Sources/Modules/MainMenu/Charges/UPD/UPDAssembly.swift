//
//  UPDAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.03.2021.
//

import Foundation

final class UPDAssembly: Assembly {
    func make() -> UIViewController {
        return UPDController()
    }
}
