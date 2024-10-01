import UIKit
import MessageUI

protocol SettingsPresenterProtocol: class {
    func changeLanguage()
    func logout()
    func getUserInfo() -> String
    func getUserPhone() -> String
}

final class SettingsPresenter: SettingsPresenterProtocol {
    private let authService: LocalAuthService
    private let user: User?
    private let panelTransition = PanelTransition()

    weak var controller: SettingsControllerProtocol?

    init(authService: LocalAuthService, user: User?) {
        self.authService = authService
        self.user = user
        panelTransition.currentPresentation = .chooseLanguageView
    }

    // MARK: - SettingsPresenterProtocol

    func changeLanguage() {
        let viewController = ChooseLanguageAssembly(delegate: nil).make()
        viewController.transitioningDelegate = panelTransition
        let router = ModalRouter(source: nil, destination: viewController, modalPresentationStyle: .custom)
        router.route()
    }

    func logout() {
        authService.deleteUser()
        controller?.routeToMain()
    }
    
    func getUserInfo() -> String {
        guard let user = self.authService.user else { return "" }
        let fullName = user.getFullName()
        let phone = user.phone
        let apartment = self.authService.apartment?.apartmentNumber ?? ""
        return "<p>\(fullName)</p><p>\(phone)</p><p>\(apartment)</p>"
    }
    
    func getUserPhone() -> String {
        guard let user = self.authService.user else { return "" }
        return user.phone
    }
}
