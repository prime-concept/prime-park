//
//  PrimeAlertAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 09.06.2021.
//

import Foundation

final class PrimeAlertAssembly: Assembly {
    
    private var title: String
    private var subtitle: String?
    private weak var delegate: PrimeAlertControllerDelegate?
    private var type: PrimeAlertView.PrimeAlertType
    
    init(
        title: String,
        subtitle: String? = nil,
        delegate: PrimeAlertControllerDelegate? = nil,
        type: PrimeAlertView.PrimeAlertType = .info("Ok")
    ) {
        self.title = title
        self.subtitle = subtitle
        self.delegate = delegate
        self.type = type
    }
    
    func make() -> UIViewController {
        let controller = PrimeAlertController(
            title: title,
            subtitle: subtitle,
            delegate: delegate,
            type: type
        )
        return controller
    }
}
