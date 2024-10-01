//
//  PrimeAlertController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 09.06.2021.
//

import Foundation

protocol PrimeAlertControllerDelegate: AnyObject {
    func buttonTapped(_ tag: Int, alert: PrimeAlertController)
}

final class PrimeAlertController: UIViewController {
    private lazy var alertView = self.view as? PrimeAlertView
    
    private weak var delegate: PrimeAlertControllerDelegate?
    
    private let titleText: String
    private let subtitleText: String?
    private var type: PrimeAlertView.PrimeAlertType

    init(
        title: String,
        subtitle: String?,
        delegate: PrimeAlertControllerDelegate?,
        type: PrimeAlertView.PrimeAlertType
    ) {
        self.titleText = title
        self.subtitleText = subtitle
        self.delegate = delegate
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = PrimeAlertView(delegate: self, title: titleText, subtitle: subtitleText, type: type)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PrimeAlertController: PrimeAlertViewDelegate {
    func buttonTapped(tag: Int) {
        if let delegate = delegate {
            delegate.buttonTapped(tag, alert: self)
            return
        }
        dismiss {}
    }
}
