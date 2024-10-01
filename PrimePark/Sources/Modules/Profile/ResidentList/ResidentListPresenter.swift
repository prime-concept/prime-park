protocol ResidentListPresenterProtocol: class {
    func addResident()
    func showInfo()
}

final class ResidentListPresenter: ResidentListPresenterProtocol {
    private let endpoint: SettingsEndpoint
    private let authService: LocalAuthService
    private let issueEndpoint = IssuesEndpoint()
    private let networkService = NetworkService()

    weak var controller: ResidentListControllerProtocol?

    init(endpoint: SettingsEndpoint, authService: LocalAuthService) {
        self.endpoint = endpoint
        self.authService = authService
        loadResidents()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteResident(notification:)), name: .needDeleteGuest, object: nil)
    }

    func addResident() {
        PushRouter(source: self.controller, destination: AddResidentAssembly(authService: self.authService).make()).route()
    }

    func showInfo() {
        ModalRouter(source: controller, destination: WebViewController(stringURL: WebViewInfoLinksConstants.roleInfoLink), modalPresentationStyle: .popover).route()
//        ModalRouter(source: controller, destination: ProfileInfoController(), modalPresentationStyle: .popover).route()
    }

    // MARK: - Private API

    private func loadResidents() {
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getResidentsList(room: String(room.id), token: accessToken)
            },
            doneCompletion: { list in
                self.controller?.residentsDidLoad(list)
            },
            errorCompletion: { error in
                print("ERROR WHILE LOAD RESIDENT LIST: \(error.localizedDescription)")
            }
        )
    }

    @objc
    private func deleteResident(notification: Notification) {
        let alert = UIAlertController(title: Localization.localize("resident.deleteResident.alert.title"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.localize("alert.button.no"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(
            title: Localization.localize("alert.button.yes"),
            style: .destructive,
            handler: { _ in
                guard let resident = notification.userInfo?["resident"] as? Resident else { return }
                self.needDeleteResident(resident)
            }
        ))
        alert.view.tintColor = .white

        self.controller?.showAlert(alert)
    }

    private func needDeleteResident(_ resident: Resident) {
        let text = createText(resident: resident)
        //{"id":"6849f4b9-0cbc-4521-a1b2-8b56fd17049f","type":0,"display_name":"Удаление роли","is_active":true,"subtype":[]}
        let type = IssueType(id: "6849f4b9-0cbc-4521-a1b2-8b56fd17049f", name: "Удаление роли")
        guard
            let room = self.authService.user?.parcingRooms[0],
            let token = self.authService.token?.accessToken
        else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.issueEndpoint.createIssue(
                    room: room.id,
                    text: text,
                    type: type,
                    token: accessToken
                )
            },
            doneCompletion: { _ in
                self.showAlertAboutSuccessIssue()
            },
            errorCompletion: { error in
                print("ERROR WHILE SEND ISSUE FOR DELETE RESIDENT: \(error.localizedDescription)")
                self.showAlertAboutErrorIssue()
            }
        )
    }

    private func createText(resident: Resident) -> String {
        var text = ""
        switch resident.getRole {
        case .brigadier:
            text = Localization.localize("resident.deleteBrigadier.text")
        case .cohabitant:
            text = Localization.localize("resident.deleteCohabitant.text")
        default:
            text = Localization.localize("resident.deleteGuest.text")
        }
        text += "\r\n"
        text += "\(Localization.localize("resident.deleteResident.fullname")) \(resident.fullName)"
        text += "\r\n"
        text += "\(Localization.localize("resident.deleteResident.phone")) \(resident.phone)"
        return text
    }

    private func showAlertAboutSuccessIssue() {
        let assembly = InfoAssembly(title: Localization.localize("resident.deleteResident.success.title"), subtitle: Localization.localize("resident.deleteResident.success.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showAlertAboutErrorIssue() {
        let assembly = InfoAssembly(title: Localization.localize("resident.deleteResident.error.title"), subtitle: Localization.localize("resident.deleteResident.error.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
}
