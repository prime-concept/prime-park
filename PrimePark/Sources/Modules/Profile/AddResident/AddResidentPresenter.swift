protocol AddResidentPresenterProtocol: class {
    func showError()
    func addResident(_ resident: Resident)
}

final class AddResidentPresenter: ErrorPresenter, AddResidentPresenterProtocol {
    private let endpoint: PassEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()

    private enum AddResidentRequest {
        case cohabitant
        case brigadier
        case guest
    }

    weak var controller: AddResidentControllerProtocol?

    private var currentRequest: AddResidentRequest = .cohabitant
    private var currentResident: Resident?

    init(endpoint: PassEndpoint, authService: LocalAuthService) {
        self.endpoint = endpoint
        self.authService = authService
    }

    func showError() {
    }

    func addResident(_ resident: Resident) {
        self.currentResident = resident
        switch resident.getRole {
        case .cohabitant:
            createCohabitantPass(at: resident)
        case .brigadier:
            createBrigadierPass(at: resident)
        case .guest:
            createGuestPass(at: resident)
        default:
            return
        }
    }

    // MARK: - Private API

    private func createCohabitantPass(at resident: Resident) {
        self.currentRequest = .cohabitant
//        #warning("Заменить на дефолтную квартиру из LocalAuthService для реального сервера")
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createPermanentPass(
                    room: String(room.id),
                    token: accessToken,
                    name: resident.name,
                    surname: resident.surname,
                    secondName: resident.secondName,
                    phone: resident.removePhoneFormat,
                    role: "cohabitant",
                    verified: true
                )
            },
            doneCompletion: { _ in
                self.showRequestSuccess()
                self.controller?.close()
            },
            errorCompletion: { error in
                print("ERROR WHILE CREATE PERMANENT PASS: \(error.localizedDescription)")
                self.showRequestError(error: error)
            }
        )
    }

    private func createBrigadierPass(at resident: Resident) {
        self.currentRequest = .brigadier
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateFrom = dateFormatter.string(from: Date())
        let dateTo = dateFormatter.string(from: Date().addingTimeInterval(60 * 60 * 24 * 180))
//        #warning("Заменить на дефолтную квартиру из LocalAuthService для реального сервера")
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createTemporalPass(
                    room: String(room.id),
                    token: accessToken,
                    name: resident.name,
                    surname: resident.surname,
                    secondName: resident.secondName,
                    phone: resident.removePhoneFormat,
                    dateFrom: dateFrom,
                    dateTo: dateTo,
                    role: "brigadier",
                    isService: false, //should be constant
                    verified: true
                )
            },
            doneCompletion: { _ in
                self.showRequestSuccess()
                self.controller?.close()
            },
            errorCompletion: { error in
                print("ERROR WHILE CREATE TEMPORAL PASS: \(error.localizedDescription)")
                self.showRequestError(error: error)
            }
        )
    }

    private func createGuestPass(at resident: Resident) {
        self.currentRequest = .guest
//        #warning("Заменить на дефолтную квартиру из LocalAuthService для реального сервера")
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createPermanentPass(
                    room: String(room.id),
                    token: accessToken,
                    name: resident.name,
                    surname: resident.surname,
                    secondName: resident.secondName,
                    phone: resident.removePhoneFormat,
                    role: "guest",
                    verified: true
                )
            },
            doneCompletion: { _ in
                self.showRequestSuccess()
                self.controller?.close()
            },
            errorCompletion: { error in
                print("ERROR WHILE CREATE PERMANENT PASS: \(error.localizedDescription)")
                switch error {
                case PrimeParkError.createPassRoleError:
                    self.identifyError(error: error, source: self.controller)
                default:
                    self.showRequestError(error: error)
                }
            }
        )
    }

    private func showRequestSuccess() {
        self.controller?.loadingDone()
        self.showSuccessInfo(source: self.controller)
    }

    private func showRequestError(error: Error) {
        self.controller?.loadingDone()
        self.identifyError(error: error, source: self.controller)
    }
}
