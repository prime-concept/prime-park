// swiftlint:disable trailing_whitespace

protocol PassForMeListPresenterProtocol: class {
    func updatePasses(count: Int, isActive: Bool)
    func getStartIssues()
}

final class PassForMeListPresenter: PassForMeListPresenterProtocol {
    private let endpoint: PassEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()
    private var currentPass: IssuePass?
    private var passes: [IssuePass] = []
    
    private var isActiveScreen: Bool = true

    weak var controller: PassForMeListControllerProtocol?

    init(endpoint: PassEndpoint, authService: LocalAuthService) {
        self.endpoint = endpoint
        self.authService = authService
    }

    
    func getStartIssues() {
        getForMeIssues(page: 1, isActive: true)
        getForMeIssues(page: 1, isActive: false)
    }
    
    

    // MARK: - Private API

    private func getForMeIssues(page: Int = 1, isActive: Bool) {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getForMeIssuesList(token: accessToken, pageNumber: page, isActive: isActive)
            },
            doneCompletion: { list in
                print(list)
                if isActive {
                    self.controller?.setActive(issues: list.results)
                } else {
                    self.controller?.setHistory(issues: list.results)
                }
            },
            errorCompletion: { error in
                self.controller?.stopRefreshing()
                print("ERROR WHILE DOWNLOAD FOR ME PASSES LIST: \(error.localizedDescription)")
            }
        )
    }
    
    func updatePasses(count: Int, isActive: Bool) {
        var page = Int(ceil(Double(count) / 20.0))
        page = page == 0 ? 2 : page + 1
        print(page)
        getForMeIssues(page: page, isActive: isActive)
    }
}
