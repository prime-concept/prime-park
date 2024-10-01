//
//  ChargesController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 15.03.2021.
//

import UIKit

//swiftlint:disable force_unwrapping trailing_whitespace

protocol ChargesControllerProtocol: AnyObject {
    func setBalance(balance: String)
    func setInvoices(invoices: [Invoice])
    func setCounters(counters: [Counter])
}

final class ChargesController: UIViewController, ChargesControllerProtocol {
    private lazy var chargesView: ChargesView = {
        return Bundle.main.loadNibNamed("ChargesView", owner: nil, options: nil)?.first as? ChargesView ?? ChargesView()
    }()
    
    var presenter: ChargesPresenterProtocol?
    
    let panelTransition = PanelTransition()
    
    override func loadView() {
        view = chargesView
        chargesView.commonInit()
        chargesView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let statusBar = UIView()
//        statusBar.frame = UIApplication.shared.statusBarFrame
//        statusBar.backgroundColor = Palette.darkColor
//        UIApplication.shared.keyWindow?.addSubview(statusBar)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
		presenter?.requestAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension ChargesController: ChargesViewDelegate {
    func openUDP() {
        PushRouter(source: self, destination: UPDAssembly().make()).route()
    }
    
    func openCounter(style: Counter.Measure, description: String) {
        PushRouter(source: self, destination: CounterAssembly(style: style, description: description).make()).route()
    }
    
	func presentInfo() {
		ModalRouter(
			source: self,
			destination: WebViewController(stringURL: "https://primeparkmanagement.ru/payment"),
			modalPresentationStyle: .popover
		).route()
	}
    
    func makeDeposit() {
        let assembly = DepositAssembly(toPay: presenter?.toPay()).make()
        panelTransition.currentPresentation = .dynamic(height: UIScreen.main.bounds.height * 0.4)
        assembly.transitioningDelegate = panelTransition
        ModalRouter(source: self, destination: assembly, modalPresentationStyle: .custom).route()
    }
}

extension ChargesController {
    func setBalance(balance: String) {
        chargesView.balance = balance
    }
    
    func setInvoices(invoices: [Invoice]) {
        chargesView.invoices = invoices
    }
    
    func setCounters(counters: [Counter]) {
        chargesView.counters = counters
    }
}
