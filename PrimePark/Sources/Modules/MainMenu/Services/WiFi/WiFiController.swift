//
//  WiFiController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.03.2021.
//
//swiftlint:disable all
final class WiFiController: UIViewController, BaseServiceControllerProtocol {
    
    var presenter: BaseServicePresenter?
    
    override func loadView() {
        view = WiFiView(
            service: .wifi,
            delegate: self)
    }
    
    func stopLoading() {
        (view as? WiFiView)?.stopLoading()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
            // Fallback on earlier versions
        }
    }
}

extension WiFiController: BaseServiceDelegate {
    func close() {
        dismiss(animated: true, completion: nil)
    }
    func chooseServiceType() {
    }
    func order(type: String) {
        presenter?.callService(descriptionText: nil)
    }
}
