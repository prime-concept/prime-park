//
//  BaseServiceController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.03.2021.
//
// swiftlint:disable trailing_whitespace

import UIKit

protocol BaseServiceControllerProtocol: ModalRouterSourceProtocol {
    var presenter: BaseServicePresenter? { get set }
    
    func stopLoading()
}

class BaseServiceController: UIViewController, BaseServiceControllerProtocol {
    private var service: Service.ServiceType
    private lazy var baseServiceView = view as? BaseService
    var presenter: BaseServicePresenter?
    
    let panelTransition = PanelTransition()
    private lazy var parametersController: ParametersController = setupParameters()
    
    init(service: Service.ServiceType) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        switch service {
        case .pantries:
            view = BaseService(service: .pantries, delegate: self)
        case .furniture:
            view = BaseService(service: .furniture, delegate: self)
        case .repair:
            view = BaseService(service: .repair, delegate: self)
        case .furniturePrimepark:
            view = BaseService(service: .furniturePrimepark, delegate: self)
        case .wifi:
            view = BaseService(service: .wifi, delegate: self)
        case .gsm:
            view = BaseService(service: .gsm, delegate: self)
        default:
            view = BaseService(service: .pantries, delegate: self)
        }
    }
    
    func stopLoading() {
        baseServiceView?.stopLoading()
    }
    
    func presentParameters() {
        ModalRouter(source: self, destination: parametersController, modalPresentationStyle: .custom).route()
    }
    private func setupParameters() -> ParametersController {
        var content: [ParametersData] = []
        switch service {
        case .pantries:
            content = [ParametersData(name: localizedWith("services.panrties.type"), isSelected: true)]
        case .gsm:
            content = [
                ParametersData(name: localizedWith("services.gsm.type.first"), isSelected: true),
                ParametersData(name: localizedWith("services.gsm.type.second"), isSelected: false)
            ]
        case .wifi:
            content = [
                ParametersData(name: localizedWith("services.wifi.type"), isSelected: true)
            ]
        case .furniture:
            content = [
                ParametersData(name: localizedWith("services.furniture.type.first"), isSelected: true),
                ParametersData(name: localizedWith("services.furniture.type.second"), isSelected: false)
            ]
        case .repair:
            content = [
                ParametersData(name: localizedWith("services.repair.type.first"), isSelected: true),
                ParametersData(name: localizedWith("services.repair.type.second"), isSelected: false)
            ]
        case .furniturePrimepark:
            content = [
                ParametersData(name: localizedWith("services.furniture.type"), isSelected: true)
            ]
        default:
            break
        }
        parametersController = ParametersAssembly(
            content: content
        ).makeAsInheritor
        
        parametersController.choosenClosure = { [weak self] (content, row) in
            self?.baseServiceView?.serviceTypeLabel.text = content.name
        }
        
        panelTransition.currentPresentation = .dynamic(height: parametersController.dynamicSize)
        
        parametersController.transitioningDelegate = panelTransition
        
        return parametersController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
            // Fallback on earlier versions
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BaseServiceController: BaseServiceDelegate {
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    func chooseServiceType() {
        presentParameters()
    }
    
    func order(type: String) {
        presenter?.type = type
        //presenter?.callService(descriptionText: nil)
    }
}
