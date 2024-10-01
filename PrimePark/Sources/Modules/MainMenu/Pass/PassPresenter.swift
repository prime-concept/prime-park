protocol PassPresenterProtocol {
    func revokePass()
}

final class PassPresenter: PassPresenterProtocol {
    private enum PassRequest {
        case revokeOneTimePass
        case revokeTemporalPass
        case revokePermanentPass
    }

    private let endpoint: PassEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()
    private let pass: IssuePass
    private let passId: Int
    private weak var passList: PassListPresenterProtocol?
    weak var controller: PassControllerProtocol?
    private var choosenDate = Date()
    private var startDate = Date()
    private var endDate = Date()
    private var entranceInt = 0
    private var entranceString = Localization.localize("Pass.entrance.front")
    private var guests: [Guest] = []
    private var currentRequest = PassRequest.revokeOneTimePass

    init(
		source: PassListPresenterProtocol?,
		endpoint: PassEndpoint,
		authService: LocalAuthService,
		pass: IssuePass,
		passId: Int
	) {
        self.passList = source
        self.endpoint = endpoint
        self.authService = authService
        self.pass = pass
        self.passId = passId
    }

    func revokePass() {
        switch pass.type {
        case .oneTime:
            revokeOneTimePass()
        default:
            revokeTemporalPass()
        }
    }

    // MARK: - Private API

    func revokeOneTimePass() {
        guard let token = authService.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.revokeOneTimePass(id: String(self.passId), token: accessToken)
            },
            doneCompletion: { _ in
                self.showSuccessRevokePass()
                self.passList?.reloadData()
            },
            errorCompletion: { error in
                print("ERROR WHILE DELETE PASS: \(error.localizedDescription)")
                self.showErrorRevokePass()
            }
        )
    }

    func revokeTemporalPass() {
        guard let token = authService.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.revokeOtherPass(id: String(self.passId), token: accessToken)
            },
            doneCompletion: { _ in
                self.showSuccessRevokePass()
                self.passList?.reloadData()
            },
            errorCompletion: { error in
                print("ERROR WHILE DELETE PASS: \(error.localizedDescription)")
                self.showErrorRevokePass()
            }
        )
    }
    
    func showSuccessRevokePass() {
        let assembly = InfoAssembly(
			title: Localization.localize("pass.revoke.success.title"),
			subtitle: nil/*Localization.localize("createPass.requestSuccess.subtitle")*/,
			delegate: self
		)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    func showErrorRevokePass() {
        let assembly = InfoAssembly(title: Localization.localize("pass.revoke.error.title"), subtitle: Localization.localize("pass.revoke.error.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
}

extension PassPresenter: InfoControllerProtocol {
    func controllerDidClose() {
        self.controller?.closeController()
    }
}
