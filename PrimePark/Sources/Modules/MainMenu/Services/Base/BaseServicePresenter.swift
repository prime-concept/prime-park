//
//  BaseServicePresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.03.2021.
//
//swiftlint:disable all
import Foundation

class BaseServicePresenter {
    private let endpoint: IssuesEndpoint = .init()
    private let authService: LocalAuthService = .shared
    private let networkService = NetworkService()
    var service: Service.ServiceType
    var issueTypeService: IssuesTypeService.IssueName = .carWash
    
    
    var type: String = ""
    var name: String = ""
    private var isNow: Bool = true
    
    init(service: Service.ServiceType) {
        self.service = service
        issueTypeService = getIssueByService(service: service)
    }
    
    weak var controller: BaseServiceControllerProtocol?
    
    func callService(descriptionText: String?) {
        let text = createServiceDescription(descriptionText: descriptionText)
        guard let type = IssuesTypeService.shared.getSomeType(issueTypeService),
              let room = self.authService.apartment,
              let token = self.authService.token?.accessToken
        else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createIssue(
                    room: room.id,
                    text: text,
                    type: type,
                    token: accessToken
                )
            },
            doneCompletion: { _ in
                self.controller?.stopLoading()
                self.showSuccessAlert()
            },
            errorCompletion: { error in
                self.controller?.stopLoading()
                print("ERROR WHILE CALL CLEANING: \(error.localizedDescription)")
                self.showErrorAlert()
            }
        )
    }
}

extension BaseServicePresenter {
    private func showSuccessAlert() {
        let assembly = InfoAssembly(title: Localization.localize("service.orderService.success.title"), subtitle: nil, delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showErrorAlert() {
        let assembly = InfoAssembly(title: Localization.localize("service.orderService.error.title"), subtitle: Localization.localize("service.orderService.error.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
}

extension BaseServicePresenter {
    func getIssueByService(service: Service.ServiceType) -> IssuesTypeService.IssueName {
        switch service {
        case .furniture:
            return .furniture
        case .repair:
            return .repair
        case .gsm:
            return .gsm
        case .pantries:
            return .pantries
        case .wifi:
            return .wifi
        case .furniturePrimepark:
            return .primeParkFurniture
        default:
            return .smartHome
        }
    }
}

extension BaseServicePresenter {
    private func createServiceDescription(descriptionText: String?) -> String {
        var text = ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        text += "\(Localization.localize("service.serviceName")): \(getName(service: service))\r\n"
        text += "\(Localization.localize("service.serviceType")): \(String(describing: type))\r\n"
        if let desText = descriptionText, !desText.isEmpty {
            text += "\(Localization.localize("service.serviceDescription")): \(String(describing: desText))\r\n"
        }
        text += "\(Localization.localize("service.serviceDate")): \(Localization.localize("dryCleaning.serviceDate.buttonTitle.now"))\r\n"
        return text
    }
}

extension BaseServicePresenter {
    func getName(service: Service.ServiceType) -> String {
        switch service {
        case .pantries:
            return localizedWith("services.panrties")
        case .gsm:
            return localizedWith("services.gsm")
        case .wifi:
            return localizedWith("services.wifi")
        case .furniture:
            return localizedWith("services.furniture")
        case .repair:
            return localizedWith("services.repair")
        case .furniturePrimepark:
            return localizedWith("services.primeparkFurniture")
        default:
            return localizedWith("services.panrties")
        }
    }
}
