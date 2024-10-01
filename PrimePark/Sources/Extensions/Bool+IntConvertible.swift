//
//  Bool+IntConvertible.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 02.02.2021.
//

import Foundation

extension Bool {
    init(_ num: Int) {
        self.init(num != 0)
    }
}
