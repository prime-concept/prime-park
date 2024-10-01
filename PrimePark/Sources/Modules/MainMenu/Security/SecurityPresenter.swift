import Foundation

protocol SecurityPresenterProtocol {
    func callback()
    func writeInChat()
    func callToSecurity()
    func callSecurityInRoom()
    func callSecurityInPark()
    func callSecurityInLobby()
}

final class SecurityPresenter: SecurityPresenterProtocol {
    private let securityPhone = "+74954812524"
    private let callBackID = ChatIdType.callBackID.rawValue
    private let securityChatID = ChatIdType.securityChatID.rawValue
    private let localAuthService = LocalAuthService.shared
    private let endpoint: SecurityEndpoint
    let issueEndpoint = IssuesEndpoint()
    private var location: Int = 0
    private var currentRequest: SecurityRequest = .inRoom
    private var currentPark: Int = 1
    private lazy var titleView: ChatNavigationTitleView = {
        let view = Bundle.main.loadNibNamed("ChatNavigationTitleView", owner: nil, options: nil)?.first as? ChatNavigationTitleView ?? ChatNavigationTitleView()
        return view
    }()
    let networkService = NetworkService()

    weak var controller: SecurityViewProtocol?

    private enum SecurityRequest {
        case inRoom
        case inPark
        case inLobby
    }

    init(endpoint: SecurityEndpoint) {
        self.endpoint = endpoint
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.userCallSecurityInPark(notification:)),
            name: Notification.Name(rawValue: "UserDidChoosePark"),
            object: nil
        )
    }

    func callback() {
        checkForNotClosed { issues in
            guard let clearIssues = issues else { return }
            let issue = clearIssues.first { $0.type.id == self.callBackID && $0.status != .closed }
            if let clearIssue = issue {
                self.openChat(with: clearIssue.id)
            } else {
                self.createIssueForChat(with: ChatIdType.callBackID.rawValue)
            }
        }
    }

    func writeInChat() {
        checkForNotClosed { issues in
            guard let clearIssues = issues else { return }
            let issue = clearIssues.first { $0.type.id == self.securityChatID && $0.status != .closed }
            if let clearIssue = issue {
                self.openChat(with: clearIssue.id)
            } else {
                self.createIssueForChat(with: ChatIdType.securityChatID.rawValue)
            }
        }
    }

    func callToSecurity() {
        if let phone = URL(string: "tel://\(securityPhone)"),
            UIApplication.shared.canOpenURL(phone) {
            UIApplication.shared.open(phone)
        }
    }

    func callSecurityInRoom() {
        self.currentRequest = .inRoom
        guard
            let token = localAuthService.token?.accessToken,
            let room = localAuthService.apartment
        else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.callInRoomSecurity(room: room.id, token: accessToken)
            },
            doneCompletion: { _ in
                self.showSuccessCallSecurityAlert()
            },
            errorCompletion: { error in
                print("ERROR WHILE CALL SECURITY IN ROOM: \(error.localizedDescription)")
                self.showErrorCallSecurityAlert()
            }
        )
    }

    func callSecurityInPark() {
        let assembly = ChooseParkAssembly(delegate: self)
        let router = ModalRouter(source: self.controller, destination: assembly.make(), modalPresentationStyle: .popover, modalTransitionStyle: .coverVertical)
        router.route()
    }

    func callSecurityInLobby() {
        self.currentRequest = .inLobby
        guard
            let room = localAuthService.apartment,
            let token = localAuthService.token?.accessToken
        else { return }
        
        let location = "100"
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.callInLobbySecurity(room: room.id, location: location, token: accessToken)
            },
            doneCompletion: { _ in
                self.showSuccessCallSecurityAlert()
            },
            errorCompletion: { error in
                print("ERROR WHILE CALL SECURITY IN LOBBY: \(error.localizedDescription)")
                self.showErrorCallSecurityAlert()
            }
        )
    }

    // MARK: - Private API

    private func callSecurityInParkRequest(_ park: Int) {
        self.currentPark = park
        
        guard let room = localAuthService.apartment,
              let token = localAuthService.token?.accessToken
        else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.callInLobbySecurity(room: room.id, location: String(park), token: accessToken)
            },
            doneCompletion: { _ in
                self.showSuccessCallSecurityAlert()
            },
            errorCompletion: { error in
                print("ERROR WHILE CALL SECURITY IN PARK: \(error.localizedDescription)")
                self.showErrorCallSecurityAlert()
            }
        )
    }

    @objc
    func userCallSecurityInPark(notification: Notification) {
        self.currentRequest = .inPark
        let park: Int = notification.userInfo?["choosenPark"] as? Int ?? 0
        self.callSecurityInParkRequest(park)
    }

    @objc
    private func closeChat() {
        self.controller?.closeChat()
    }
}

// MARK: - Alerts

extension SecurityPresenter {
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

    private func showSuccessCallSecurityAlert() {
        let assembly = InfoAssembly(title: Localization.localize("security.callSecurity.success.title"), subtitle: Localization.localize("security.callSecurity.success.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
    
    private func showErrorCallSecurityAlert() {
        let assembly = InfoAssembly(title: Localization.localize("security.callSecurity.error.title"), subtitle: Localization.localize("security.error.callSecurity.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
}

// MARK: - SingleChatInteractionProtocol

extension SecurityPresenter: SingleChatInteractionProtocol {
    internal func openChat(with id: String) {
        guard let username = localAuthService.user?.username, !username.isEmpty,
            let token = localAuthService.token?.accessToken, !token.isEmpty,
            let sourceController = self.controller else { return }
        let chatController = ChatAssembly(
            chatToken: token,
            channelID: "PPI\(id)",
            channelName: Localization.localize("security.chatWithSecurity.title"),
            clientID: "C\(username)",
            item: nil,
            sourceViewController: sourceController
        ).make()
        let navController = PrimeParkNavigationController(rootViewController: chatController)
        //navController.addChild(chatController)
        let image = UIImage(named: "back_button")?.withRenderingMode(.alwaysOriginal)
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.closeChat))
        //chatController.navigationItem.leftBarButtonItem = item
        chatController.navigationItem.setLeftBarButton(item, animated: false)
        navController.closeCompletion = { self.closeChat() }
        ModalRouter(source: sourceController, destination: navController).route()
    }
    internal func createIssueForChat(with type: String) {
        guard let type = IssuesTypeService.shared.getType(at: type),
              let room = localAuthService.apartment,
              let token = localAuthService.token?.accessToken
        else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.issueEndpoint.createIssue(
                    room: room.id,
                    text: Localization.localize("service.chatWithSecurity"),
                    type: type,
                    token: accessToken
                )
            },
            doneCompletion: { _ in
                self.showSuccessAlert()
            },
            errorCompletion: { error in
                print("ERROR WHILE CREATE SECURITY CHAT ISSUE: \(error.localizedDescription)")
            }
        )
    }
    internal func checkForNotClosed(completionHandler: @escaping ([Issue]?) -> Void) {
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.issueEndpoint.getIssuesList(token: accessToken)
            },
            doneCompletion: { list in
                completionHandler(list)
            },
            errorCompletion: { error in
                completionHandler(nil)
                print("ERROR WHILE DOWNLOAD MY ISSUES LIST: \(error.localizedDescription)")
            }
        )
    }
}

extension SecurityPresenter: ChooseParkViewDelegate {
    func parkDidChoose(park: Int) {
        print("УРА! МОЖНО ОТПРАВИТЬ ЗАПРОС!!!")
    }
}
