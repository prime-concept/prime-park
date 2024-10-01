//swiftlint:disable force_unwrapping

protocol CreatePassPresenterProtocol {
    func openCalendar(interval: Bool)
    func choosenEntrance(entrance: Entrance)
    func needAddGuest()
    func createPass(type: PassType)
    func createParking(carNumber: String, guest: Guest, isResidentPay: Bool)
    func guestDidDelete(index: Int)
    func showGuestsError()
    func showNoGuestsError()
    func showNoCarDataError()
    func getPermissions() -> [PassType]
    func showInfo()
    func showParkingAlert()
}

enum CreatePassRequest {
    case oneTimeRequest
    case oneDayRequest
    case temporalRequest
    case permanentRequest
}
//swiftlint:disable type_body_length trailing_whitespace function_body_length
final class CreatePassPresenter: PassWithErrorPresenter, CreatePassPresenterProtocol {

    private let endpoint: PassEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()
    private let recentGuests: [Guest]

    weak var controller: CreatePassControllerProtocol?
    private var choosenDate = Date().dateWithCurrentTimeZone()
    private var startDate = Date()
    private var endDate = Date()//cntr z
    private var entranceInt = 0
    private var entranceString = Localization.localize("createPass.entrance.front")
    private var currentRequest = CreatePassRequest.oneTimeRequest
    private var permissions: [PassType] = []
    private let parkingEndpoint = ParkingEndpoint()
    private var barcode: Barcode?
    private var currentBarcodeModelId: String = ""

    init(endpoint: PassEndpoint, authService: LocalAuthService, pass: IssuePass?, recentGuests: [Guest]) {
        self.endpoint = endpoint
        self.authService = authService
        self.recentGuests = recentGuests
        switch authService.apartment?.getRole {
        case .resident:
            permissions = [.oneTime, .oneDay, .temporary, .permanent]
        case .cohabitant, .brigadier:
            permissions = [.oneTime, .oneDay, .temporary]
        default:
            permissions = []
        }
        super.init()
        addListener()
        self.loadBarcodeModel()
        guard let pass = pass else { return }
        guests.append(Guest(name: pass.firstName, surname: pass.lastName, patronymic: pass.middleName, phone: pass.phone))
    }

    func openCalendar(interval: Bool) {
        let calendarController = CalendarViewController(delegate: self, interval: interval)
        let router = ModalRouter(source: self.controller, destination: calendarController, modalPresentationStyle: .popover, modalTransitionStyle: .coverVertical)
        router.route()
    }
    
    func choosenEntrance(entrance: Entrance) {
        entranceInt = entrance.rawValue
        entranceString = entrance.localizedName
    }

    func needAddGuest() {
        let controller = AddGuestController(delegate: self, recentGuests: recentGuests)
        self.controller?.present(module: controller)
    }

    func createPass(type: PassType) {
        self.needError = false
        switch type {
        case .oneTime:
            for guest in guests {
                createOneTimePass(name: guest.name, surname: guest.surname, secondName: guest.patronymic, phone: guest.removePhoneFormat)
            }
        case .oneDay:
            for guest in guests {
                createOneDayPass(name: guest.name, surname: guest.surname, secondName: guest.patronymic, phone: guest.removePhoneFormat)
            }
        case .temporary:
            for guest in guests {
                createTemporaryPass(name: guest.name, surname: guest.surname, secondName: guest.patronymic, phone: guest.removePhoneFormat)
            }
        case .permanent:
            for guest in guests {
                createPermanentPass(name: guest.name, surname: guest.surname, secondName: guest.patronymic, phone: guest.removePhoneFormat)
            }
        default:
            return
        }
    }

    func showGuestsError() {
        showGuestsError(source: self.controller)
    }

    func showNoGuestsError() {
        showNoGuestsError(source: self.controller)
    }

    func guestDidDelete(index: Int) {
        guests.remove(at: index)
    }

    func getPermissions() -> [PassType] {
        return permissions
    }

    func showInfo() {
        ModalRouter(
            source: nil,
            destination: WebViewController(stringURL: WebViewInfoLinksConstants.passInfoLink),
            modalPresentationStyle: .popover
        ).route()
    }

    func createParking(carNumber: String, guest: Guest, isResidentPay: Bool) {
        chooseBarcodeModel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let date = dateFormatter.string(from: choosenDate)
//        #warning("Заменить на дефолтную квартиру из LocalAuthService для реального сервера")
		guard let token = self.authService.token?.accessToken else { return }

		guard let room = self.authService.room else { return }
        guard let barcode = self.barcode else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.parkingEndpoint.createOneTimeParkingIssue(
    //                companyID: room.number,
                    companyID: barcode.companyID,
                    barcodeModel: self.currentBarcodeModelId,
                    room: room.id,
                    carNumber: carNumber,
                    carModel: "",
                    guestName: guest.fullName,
                    guestPhone: guest.removePhoneFormat,
                    date: date,
                    token: accessToken
                )
            },
            doneCompletion: { _ in
                self.controller?.loadingDone()
            },
            errorCompletion: { error in
                self.controller?.loadingDone()
                print("ERROR WHILE CREATE ONETIME PARKING: \(error.localizedDescription)")
            }
        )
    }

    func showNoCarDataError() {
        showNoCarDataError(source: self.controller)
    }

    func showParkingAlert() {
        self.showParkingAlert(source: self.controller)
    }

    // MARK: - Private API

    private func createOneTimePass(name: String, surname: String, secondName: String?, phone: String) {
        self.currentRequest = .oneTimeRequest
        self.amountOfRequests = self.guests.count
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        
        let dates = actualiseChoosenDate(dates: [choosenDate])
        
        let dateFromStr = dateFormatter.string(from: dates.from)
        let dateToStr = dateFormatter.string(from: dates.to)
//        #warning("Заменить на дефолтную квартиру из LocalAuthService для реального сервера")

        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createOneTimePass(
                    room: String(room.id),
                    token: accessToken,
                    name: name,
                    surname: surname,
                    secondName: secondName,
                    phone: phone,
                    dateFrom: dateFromStr,
                    dateTo: dateToStr,
                    role: "guest",
                    isService: Bool(self.entranceInt))
            },
            doneCompletion: { response in
                self.controller?.loadingDone()
                self.idArr.append(response.id)
                self.calculateAmountOfRequests(source: self.controller, phone: phone)
            },
            errorCompletion: { error in
                self.controller?.loadingDone()
                self.amountOfRequests -= 1
                print("ERROR WHILE CREATE ONETIME PASS: \(error.localizedDescription)")
                self.needError = true
                if self.amountOfRequests == 0 {
                    self.updateGuests(source: self.controller)
                    //self.showRequestError(source: self.controller)
                    self.identifyError(error: error, source: self.controller)
                }
            }
        )
    }

    private func createOneDayPass(name: String, surname: String, secondName: String?, phone: String) {
        self.currentRequest = .oneDayRequest
        self.amountOfRequests = self.guests.count
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        
        let dates = actualiseChoosenDate(dates: [choosenDate])
        
        let dateFromStr = dateFormatter.string(from: dates.from)
        let dateToStr = dateFormatter.string(from: dates.to)
        
//        #warning("Заменить на дефолтную квартиру из LocalAuthService для реального сервера")
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createTemporalPass(
                    room: String(room.id),
                    token: accessToken,
                    name: name,
                    surname: surname,
                    secondName: secondName,
                    phone: phone,
                    dateFrom: dateFromStr,
                    dateTo: dateToStr,
                    role: "guest",
                    isService: Bool(self.entranceInt)
                )
            },
            doneCompletion: { response in
                self.controller?.loadingDone()
                self.idArr.append(response.id)
                self.calculateAmountOfRequests(source: self.controller, phone: phone, requestType: self.currentRequest)
            },
            errorCompletion: { error in
                self.controller?.loadingDone()
                self.amountOfRequests -= 1
                print("ERROR WHILE CREATE ONEDAY PASS: \(error.localizedDescription)")
                self.needError = true
                if self.amountOfRequests == 0 {
                    self.updateGuests(source: self.controller)
                    //self.showRequestError(source: self.controller)
                    self.identifyError(error: error, source: self.controller)
                }
            }
        )
    }

    private func createTemporaryPass(name: String, surname: String, secondName: String?, phone: String) {
        self.currentRequest = .temporalRequest
        self.amountOfRequests = self.guests.count
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        
        let dates = actualiseChoosenDate(dates: [startDate, endDate])
        
        let dateFromStr = dateFormatter.string(from: dates.from)
        let dateToStr = dateFormatter.string(from: dates.to)
        
//        #warning("Заменить на дефолтную квартиру из LocalAuthService для реального сервера")
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createTemporalPass(
                    room: String(room.id),
                    token: accessToken,
                    name: name,
                    surname: surname,
                    secondName: secondName,
                    phone: phone,
                    dateFrom: dateFromStr,
                    dateTo: dateToStr,
                    role: "guest",
                    isService: Bool(self.entranceInt)
                )
            },
            doneCompletion: { response in
                self.controller?.loadingDone()
                self.idArr.append(response.id)
                self.calculateAmountOfRequests(source: self.controller, phone: phone, requestType: self.currentRequest)
            },
            errorCompletion: { error in
                self.controller?.loadingDone()
                self.amountOfRequests -= 1
                print("ERROR WHILE CREATE TEMPORAL PASS: \(error.localizedDescription)")
                self.needError = true
                if self.amountOfRequests == 0 {
                    self.updateGuests(source: self.controller)
                    //self.showRequestError(source: self.controller)
                    self.identifyError(error: error, source: self.controller)
                }
            }
        )
    }

    private func createPermanentPass(name: String, surname: String, secondName: String?, phone: String) {
        self.currentRequest = .permanentRequest
        self.amountOfRequests = self.guests.count
//        #warning("Заменить на дефолтную квартиру из LocalAuthService для реального сервера")
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createPermanentPass(
                    room: String(room.id),
                    token: accessToken,
                    name: name,
                    surname: surname,
                    secondName: secondName,
                    phone: phone,
                    role: "guest"
                )
            },
            doneCompletion: { response in
                self.controller?.loadingDone()
                self.idArr.append(response.id)
                self.calculateAmountOfRequests(source: self.controller, phone: phone, requestType: self.currentRequest)
            },
            errorCompletion: { error in
                self.controller?.loadingDone()
                self.amountOfRequests -= 1
                print("ERROR WHILE CREATE PERMANENT PASS: \(error.localizedDescription)")
                self.needError = true
                if self.amountOfRequests == 0 {
                    self.updateGuests(source: self.controller)
                    //self.showRequestError(source: self.controller)
                    self.identifyError(error: error, source: self.controller)
                }
            }
        )
    }

    private func fixLastDateFromLibrary(_ date: Date) -> Date {
        return Date.init(timeInterval: 60 * 60 * 24, since: date)
    }

    private func loadBarcodeModel() {
        guard let token = self.authService.token?.accessToken else { return }
		guard let room = self.authService.room else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.parkingEndpoint.getBarcodeModel(companyName: room.number, token: accessToken)
            },
            doneCompletion: { barcode in
                self.barcode = barcode
            },
            errorCompletion: { error in
                print("ERROR WHILE LOAD BARCODEMODEL: \(error.localizedDescription)")
            }
        )
    }

    private func chooseBarcodeModel() {
        #warning("Выбрать тип в зависимости от условий")
        if let barcode = self.barcode {
            self.currentBarcodeModelId = barcode.models[0].id
        }
    }
}

extension CreatePassPresenter: CalendarViewControllerDelegate {
    func choosenDate(date: Date) {
        self.choosenDate = date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(identifier: "UTC")!
        self.controller?.setChoosenDate(date: formatter.string(from: date))
    }

    func choosenInterval(start: Date, end: Date) {
        self.startDate = start
        self.endDate = end
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(identifier: "UTC")!
        self.controller?.setChoosenInterval(interval: "\(formatter.string(from: start)) - \(formatter.string(from: end))")
    }
}

extension CreatePassPresenter: AddGuestControllerDelegate {
    func guestAdded(_ guest: Guest) {
        guests.append(guest)
        self.controller?.guestDidAdd(guest)
    }
}

extension CreatePassPresenter {
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


extension CreatePassPresenter {
    func actualiseChoosenDate(dates: [Date]) -> (from: Date, to: Date) {
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        guard
            let firstDate = dates.first,
            let lastDate = dates.last
        else { fatalError("param: dates cannot be empty!") }
        
        var fromDateComponents = calendar.dateComponents([.year, .month, .day], from: firstDate)
        fromDateComponents.hour = 0
        fromDateComponents.minute = 0
        fromDateComponents.second = 0
        
        var toDateComponents = calendar.dateComponents([.year, .month, .day], from: lastDate)
        toDateComponents.hour = 23
        toDateComponents.minute = 59
        toDateComponents.second = 59
        
        let fromDate = calendar.date(from: fromDateComponents)
        let toDate = calendar.date(from: toDateComponents)
        
        return (fromDate!, toDate!)
    }
}
