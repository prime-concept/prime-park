// swiftlint:disable trailing_whitespace

protocol PassListPresenterProtocol: class {
    func updatePasses(isActive: Bool)
    func createNewPass()
    func showDetail(for pass: IssuePass)
    func reloadData()
    func canCreatePass() -> Bool
    func showInfo()
    func needDeleteCurrentPass()
    
    func getStartIssues()
}

final class PassListPresenter: PassListPresenterProtocol {

    private let endpoint: PassEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()
	private let dispatchGroup = DispatchGroup()
    private var currentPass: IssuePass?
    private var passes: [IssuePass] = []
    private var pages = (active: 1, history: 1)
    
    private var isActiveScreen: Bool = true

    weak var controller: PassListControllerProtocol?

    init(endpoint: PassEndpoint, authService: LocalAuthService) {
        self.endpoint = endpoint
        self.authService = authService
        NotificationCenter.default.addObserver(self, selector: #selector(self.repeatPass), name: NSNotification.Name(rawValue: "NeedRepeatPass"), object: nil)
        //getMyIssues()
        //getForMeIssues()
    }

    /*func choosenRequest(item: Pass) {
        guard let username = authService.user?.username, !username.isEmpty,
            let token = authService.token?.accessToken, !token.isEmpty
        else {
            fatalError("User doesn`t exist")
        }
    }*/

    func createNewPass() {
        let guests = getRecentGuestsArray()
        PushRouter(
			source: controller,
			destination: CreatePassAssembly(
				authService: authService,
				pass: currentPass,
				recentGuests: guests
			).make()
		).route()
    }

    func showDetail(for pass: IssuePass) {
        currentPass = pass
        let passID = pass.sharedId
        ModalRouter(source: controller, destination: PassAssembly(source: self, authService: authService, pass: pass, passID: passID).make(), modalPresentationStyle: .popover).route()
    }

    func reloadData() {
        getMyIssues(isActive: isActiveScreen)
    }

    func canCreatePass() -> Bool {
        guard let room = authService.apartment else {
            return false
        }
        return room.getRole != .guest
    }

    func showInfo() {
        ModalRouter(source: controller, destination: WebViewController(stringURL: WebViewInfoLinksConstants.passInfoLink), modalPresentationStyle: .popover).route()
    }

    func needDeleteCurrentPass() {
        currentPass = nil
    }
    
    func getStartIssues() {
        getMyIssues(page: 1, isActive: true)
		
		dispatchGroup.notify(queue: NetworkService.workingQueue) { [weak self] in
			self?.getMyIssues(page: 1, isActive: false)
		}
    }

    // MARK: - Private API

    private func getMyIssues(page: Int = 1, isActive: Bool) {
		self.dispatchGroup.enter()
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getMyIssuesList(token: accessToken, pageNumber: page, isActive: isActive)
            },
            doneCompletion: { list in
				self.dispatchGroup.leave()
				
                self.passes = list.results
                
                if isActive {
                    self.controller?.setActive(issues: list.results, isStart: page == 1)
                    self.pages.active += 1
                } else {
                    self.controller?.setHistory(issues: list.results, isStart: page == 1)
                    self.pages.history += 1
                }
            },
            errorCompletion: { error in
				self.dispatchGroup.leave()
                self.controller?.stopRefreshing()
                print("ERROR WHILE DOWNLOAD MY PASSES LIST: \(error.localizedDescription)")
            }
        )
    }

    @objc
    private func repeatPass() {
        createNewPass()
    }
    
    func updatePasses(isActive: Bool) {
        let page = isActive ? (self.pages.active) : (self.pages.history)
        getMyIssues(page: page, isActive: isActive)
    }

    private func getRecentGuestsArray() -> [Guest] {
        var phonesArray: [String] = []
        var guestsArray: [Guest] = []
        for issue in passes {
            if phonesArray.contains(issue.phone) {
                continue
            }
            phonesArray.append(issue.phone)
            guestsArray.append(Guest(name: issue.firstName, surname: issue.lastName, patronymic: issue.middleName, phone: issue.phone))
        }
        return guestsArray
    }
}
