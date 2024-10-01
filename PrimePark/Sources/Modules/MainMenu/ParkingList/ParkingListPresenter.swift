//swiftlint:disable all

import Foundation

extension Notification.Name {
	static let parkingListReloadRequested = Notification.Name("parkingListReloadRequested")
}

protocol ParkingListPresenterProtocol: class {
    //func choosenRequest(item: Parking)
	func repeatParking(_ parking: Parking)
    func createNewIssue()
    func reloadData()
    func canCreateParking() -> Bool
    func showInfo()
    
    //permanent section
    
    func setService(service: CreateParkingIssues)
    func setCarsAmount(amount: String)
    func setMonthAmount(amount: String)
    func createPermanent()
    
    var getServiceType: CreateParkingIssues { get }
    
    //valet section
    
    //func getValetCards(cardType: ParkingTicket.CardType)
    func getAllValetCards()
    func showWarningAlert()
    func backToParkingList()
    
    func setNewTicketTitle(tn: String, newTitle: String)
}

final class ParkingListPresenter: ParkingListPresenterProtocol {

    private let parkingEndpoint: ParkingEndpoint
    private let valetEndpoint: ValetEndpoint = .init()
    
    private let authService: LocalAuthService
    private let networkService = NetworkService()
    private var onetimeParkingArray: [Parking] = []
    
    //permanent section
    private var issuesEndpoint: IssuesEndpoint
    
    private var currentServiceType: CreateParkingIssues = .privateValetParking
    private var currentCarsAmount: String = ""
    private var currentMonthAmount: String = ""
    //
    
    private let dispatchGroup = DispatchGroup()
    

    weak var controller: ParkingListControllerProtocol?

    init(endpoint: ParkingEndpoint, authService: LocalAuthService) {
        self.parkingEndpoint = endpoint
        self.authService = authService
        self.issuesEndpoint = IssuesEndpoint()
        addListener()
        getOnetimeParking()

		Notification.onReceive(.parkingListReloadRequested) { [weak self] _ in
			self?.reloadData()
		}
    }

	func repeatParking(_ parking: Parking) {
		let recentGuests = getRecentGuestsArray()
		PushRouter(source: self.controller, destination: CreateParkingAssembly(authService: self.authService, recentGuests: recentGuests, parking: parking).make()).route()
	}

    func createNewIssue() {
        let recentGuests = getRecentGuestsArray()
        PushRouter(source: self.controller, destination: CreateParkingAssembly(authService: self.authService, recentGuests: recentGuests).make()).route()
    }

    func reloadData() {
        getOnetimeParking()
    }

    func canCreateParking() -> Bool {
        guard let room = authService.apartment else {
            return false
        }
        return room.getRole != .guest
    }

    func showInfo() {
        ModalRouter(source: controller, destination: WebViewController(stringURL: WebViewInfoLinksConstants.parkInfoLink), modalPresentationStyle: .popover).route()
    }

    // MARK: - Private API PARKING

    private func getOnetimeParking() {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.parkingEndpoint.getParkingList(token: accessToken)
            },
            doneCompletion: { list in
                self.onetimeParkingArray = list
                self.controller?.setOneTimeParking(list: list)
            },
            errorCompletion: { error in
                print("ERROR WHILE DOWNLOAD ONE-IME PARKING LIST: \(error.localizedDescription)")
            }
        )
    }
    
    private func createPermanentParking() {
        print("SSH", currentServiceType.rawValue)
        guard let type = IssuesTypeService.shared.getType(at: currentServiceType.rawValue),
              let room = self.authService.apartment,
              let token = self.authService.token?.accessToken
        else { return }

        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.issuesEndpoint.createIssue(
                    room: room.id,
                    text: self.formatedText,
                    type: type,
                    token: accessToken
                )
            },
            doneCompletion: { issueData in
                self.showSuccessInfo()
                self.controller?.createPermanentDone()
            },
            errorCompletion: { error in
                self.showRequestError()
                print("ERROR WHILE CREATE SECURITY CHAT ISSUE: \(error.localizedDescription)")
            }
        )
    }
    
    private func getValetCards(cardType: ParkingTicket.CardType) {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.valetEndpoint.getParkingCards(token: accessToken, cardType: cardType)
            },
            doneCompletion: { cards in
                self.controller?.viewProtocol.reloadData(with: cards.results)
            },
            errorCompletion: { error in
                print("ERROR WHILE DOWNLOAD ONE-IME PARKING LIST: \(error.localizedDescription)")
            }
        )
    }
    
    func getAllValetCards() {
        self.getTenantStatus()
    }
    
    private func getTenantStatus() {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.valetEndpoint.getTenantStatus(token: accessToken)
            },
            doneCompletion: { tenantStatus in
                print(tenantStatus)
                if tenantStatus.result == "active" {
                    self.getValetCards(cardType: .all)
                } else {
                    self.getValetCards(cardType: .ticket)
                }
            },
            errorCompletion: { error in
                self.getValetCards(cardType: .ticket)
                print("\(error.localizedDescription)")
            }
        )
    }
    
    func setNewTicketTitle(tn: String, newTitle: String) {
        guard let token = self.authService.token?.accessToken else { return }
        
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.valetEndpoint.setParkingTitle(token: accessToken, tn: tn, title: newTitle)
            },
            doneCompletion: { tenantStatus in
                print("doneCompletion")
            },
            errorCompletion: { error in
                print("\(error.localizedDescription)")
            }
        )
    }
    
}

extension ParkingListPresenter {
    
    func createPermanent() {
        self.createPermanentParking()
    }
    
    func setService(service: CreateParkingIssues) {
        self.currentServiceType = service
    }
    
    var getServiceType: CreateParkingIssues {
        return currentServiceType
    }
    
    func setCarsAmount(amount: String) {
        self.currentCarsAmount = amount
    }
    
    func setMonthAmount(amount: String) {
        self.currentMonthAmount = amount
    }
    
    var formatedText: String {
        return "Тип услуги: \(currentServiceType.name)\nКоличество машин: \(currentCarsAmount)\nСрок абонемента: \(currentMonthAmount)"
    }
    
    func showWarningAlert() {
         warningAlert()
    }
}

extension ParkingListPresenter {
    private func showRequestError() {
        let assembly = InfoAssembly(
            title: localizedWith("createParking.createOrder.error.title"),
            subtitle: localizedWith("createParking.createOrder.error.subtitle"),
            delegate: nil,
            status: .failure
        )
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showSuccessInfo() {
        let assembly = InfoAssembly(
            title: localizedWith("createParking.permanent.createOrder.success.title"),
            subtitle: localizedWith("createParking.permanent.createOrder.success.subtitle"),
            delegate: nil,
            status: .success
        )
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
    
    private func warningAlert() {
//        let assembly = InfoAssembly(
//            title: localizedWith("parking.segmentedControl.valet.alert.subtitle"),
//            subtitle: nil,
//            delegate: nil,
//            status: .success
//        )
//        let router = ModalRouter(source: self.controller, destination: assembly.make())
//        router.route()
        
        let alert = UIAlertController(
            title: Localization.localize("parking.segmentedControl.valet.alert.subtitle"),
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: Localization.localize("alert.button.yes"),
            style: .default,
            handler: nil
        ))
        alert.addAction(UIAlertAction(
            title: Localization.localize("alert.button.no"),
            style: .cancel,
            handler: { _ in
                self.backToParkingList()
            }))
        //alert.view.layer.cornerRadius = 22
        alert.view.tintColor = .white

        self.controller?.present(module: alert)
    }
    
    func backToParkingList() {
        controller?.viewProtocol.changeSegmentControlIndex(0)
    }
}

extension ParkingListPresenter {
    @objc
    func changeAccess(notification: Notification) {
        guard let rooms = LocalAuthService.shared.user?.parcingRooms else { return }
        guard let index = notification.userInfo?["roomNumber"] as? Int else { return }
        self.controller?.changeAccess(rooms[index].getRole)
    }
    func addListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeAccess(notification:)), name: .roomChanged, object: nil)
    }
}

extension ParkingListPresenter {
    private func getRecentGuestsArray() -> [Guest] {
        var phonesArray: [String] = []
        var guestsArray: [Guest] = []
        for parking in onetimeParkingArray {
            if phonesArray.contains(parking.phone) {
                continue
            }
            phonesArray.append(parking.phone)
            guestsArray.append(Guest(fullName: parking.name, phone: parking.phone))
        }
        return guestsArray
    }
}
