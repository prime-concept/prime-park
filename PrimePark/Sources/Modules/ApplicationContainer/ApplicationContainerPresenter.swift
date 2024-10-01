import Foundation

protocol ApplicationContainerPresenterProtocol {
    func didLoad()
}

final class ApplicationContainerPresenter: ApplicationContainerPresenterProtocol {
    private let authService: LocalAuthService
    private let endpoint: AuthEndpoint
    private let networkService = NetworkService()

    weak var controller: ApplicationContainerViewProtocol?

    init(authService: LocalAuthService, endpoint: AuthEndpoint) {
        self.authService = authService
        self.endpoint = endpoint
    }

    func didLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogin),
            name: .loggedIn,
            object: nil
        )

        guard self.authService.isAuthorized, let refreshToken = self.authService.token?.refreshToken else {
            self.controller?.displayModule(assembly: AuthAssembly())
            return
        }

        if let date = self.authService.token?.expireDate, date < Date().dateWithCurrentTimeZone() {
            guard let user = authService.user else { return }
            networkService.refreshToken(refreshToken, user.username, callback: { _ in
                self.showAppContent()
            })
            return
        }

        self.showAppContent()
    }

    @objc
    private func handleLogin() {
        self.showAppContent()
    }

    private func showAppContent() {
        guard let user = self.authService.user else {
            return
        }

        self.controller?.displayModule(
            assembly: user.grantedAuthorities.contains("ROLE_PARTNER")
                ? ChatListAssembly()
                : PrimeParkTabbarAssembly()
        )
    }
}
