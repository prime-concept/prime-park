import Foundation
import OneSignal

protocol VerificationPresenterProtocol {
    func verify(with code: String)
    func sendCode()
}
//swiftlint:disable all
final class VerificationPresenter: VerificationPresenterProtocol {
    private let endpoint: AuthEndpoint
    private let authService: LocalAuthService
    //private let metricaService: MetricService = .shared
    private let networkService = NetworkService()

    private let phone: String

    private var user: User?

    weak var controller: VerificationViewProtocol?

    init(endpoint: AuthEndpoint, phone: String, authService: LocalAuthService) {
        self.endpoint = endpoint
        self.phone = phone
        self.authService = authService
    }

    func verify(with code: String) { //done
        networkService.request(
            isRefreshing: false,
			accessToken: "",
            requestCompletion: { _ in
                self.endpoint.verify(phone: self.phone, key: code)
            },
            doneCompletion: { user in
                if user.verified {
                    self.user = user
                    self.fetchOAuthToken(with: code)
                    let userDefaults = UserDefaults.standard
                    userDefaults.setValue(user.phone, forKey: "phone")
                    userDefaults.setValue(code, forKey: "code")
                    OneSignal.sendTag("id", value: user.domaId)
                } else {
                    PushRouter(source: self.controller, destination: ModerationAssembly(pass: nil).make()).route()
                }
            },
            errorCompletion: { error in
                print("ERROR WHILE VERIFY: \(error.localizedDescription)")
                switch error {
                case PrimeParkError.invalidCode:
                    self.showSMSError()
                case PrimeParkError.codeIsCancelled:
                    self.showRepeatCodeError()
                case PrimeParkError.maximumAttempts:
                    self.showAttemptsError()
                default:
                    self.showDefaultError()
                }
            }
        )
    }

    func sendCode() {
        networkService.request(
            isRefreshing: false,
			accessToken: "",
            requestCompletion: { _ in
                self.endpoint.register(phone: self.phone)
            },
            errorCompletion: { error in
                print("ERROR WHILE VERIFY: \(error.localizedDescription)")
            }
        )
    }

    private func fetchOAuthToken(with code: String) { //done
        guard let user = user else {
            fatalError("User doesn`t exist")
        }
        
        networkService.request(
            isRefreshing: false,
			accessToken: "",
            requestCompletion: { _ in
                self.endpoint.fetchOauthToken(username: user.username, code: code)
            },
            doneCompletion: { accessToken in
				print("REFRESH TOKEN: ", accessToken.refreshToken)
                self.downloadXML(user: user, accessToken: accessToken)
            },
            errorCompletion: { error in
                print("ERROR WHILE FETCH OAUTH TOKEN: \(error.localizedDescription)")
            }
        )
    }

    func downloadXML(user: User, accessToken: AccessToken) {
        networkService.request(
			accessToken: accessToken.accessToken,
            requestCompletion: { accessToken in
                self.endpoint.getXMLFile(with: accessToken)
            },
            doneCompletion: { configArray in
                self.authService.auth(user: user, accessToken: accessToken, configs: configArray)
            },
            errorCompletion: { error in
                print("ERROR WHILE DOWNLOAD XML FILE: \(error.localizedDescription)")
            }
        )
    }

    // MARK: - Private API

    private func showSMSError() {
        let assembly = InfoAssembly(title: Localization.localize("error.authorization.invalidCode.title"), subtitle: Localization.localize("error.authorization.invalidCode.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showAttemptsError() {
        let assembly = InfoAssembly(
            title: Localization.localize("error.authorization.maximumAttempts.title"),
            subtitle: Localization.localize("error.authorization.maximumAttempts.subtitle"),
            delegate: nil
        )
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showDefaultError() {
        let assembly = InfoAssembly(title: Localization.localize("error.authorization.invalidCode.title"), subtitle: Localization.localize("error.authorization.invalidCode.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showRepeatCodeError() {
        let assembly = InfoAssembly(
            title: Localization.localize("error.authorization.codeIsCancelled.title"),
            subtitle: Localization.localize("error.authorization.codeIsCancelled.subtitle"),
            delegate: nil
        )
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
}
