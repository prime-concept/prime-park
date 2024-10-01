//
//  ValetModalAbonementController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 19.05.2021.
//

import UIKit

protocol ValetModalAbonementControllerProtocol: ModalRouterSourceProtocol {
    func startLoading()
    func successOrder()
    func failureOrder()
}

class ValetModalAbonementController: PannableViewController, ValetModalAbonementControllerProtocol {

    private lazy var abonementView: ValetModalAbonementView = {
        Bundle.main.loadNibNamed("ValetModalAbonementView", owner: nil, options: nil)?.first as? ValetModalAbonementView ?? ValetModalAbonementView()
    }()
    
    var presenter: ValetModalAbonementPresenterProtocol
    
    override func loadView() {
        view = abonementView
        abonementView.delegate = self
    }
    
    init(presenter: ValetModalAbonementPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    func startLoading() {
        abonementView.startLoading()
    }
    
    func successOrder() {
        abonementView.stopLoading()
        dismiss {
            AlertService.presentAlert(title: "Ваш запрос принят. С Вами свяжется менеджер оператора парковки.")
        }
    }
    
    func failureOrder() {
        abonementView.stopLoading()
        dismiss {
            AlertService.presentAlert(title: "Произошла ошибка!")
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ValetModalAbonementController: ValetModalAbonementViewDelegate {
    func makeOrder(with tariff: ValetAbonementTariff) {
        presenter.makeOrderRequest(tariff: tariff)
    }
}

enum ValetAbonementTariff: String {
    case oneMonth = "parking.type.valet.abonement.one.month"
    case twoMonth = "parking.type.valet.abonement.two.month"
    case sixMonth = "parking.type.valet.abonement.six.month"
}
