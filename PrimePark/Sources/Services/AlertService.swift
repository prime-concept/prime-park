//
//  AlertService.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 09.06.2021.
//

import Foundation

final class AlertService {
    class func presentAlert(
        title: String,
        subtitle: String? = nil,
        delegate: PrimeAlertControllerDelegate? = nil,
        type: PrimeAlertView.PrimeAlertType = .info("Ок")
    ) {
        ModalRouter(
            source: nil,
            destination:
                PrimeAlertAssembly(
                    title: title,
                    subtitle: subtitle,
                    delegate: delegate,
                    type: type
                ).make()
        ).route()
    }
}
