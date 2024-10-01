protocol CreateParkingPresenterProtocol {
    func openCalendar()
    func needAddGuest()
    func createParking(type: ParkingType, carNumber: String, carModel: String?, isResidentPay: Bool)
    func guestDidDelete(index: Int)
    func choosenPayer(isResident: Bool)
    func choosenEntrance(entrance: Entrance)
    func showGuestsError()
    func showEmptyDataError()
    func showInfo()
}

final class CreateParkingPresenter: CreateParkingPresenterProtocol {
    private enum CreateParkingRequest {
        case oneTimeRequest
        case permanentRequest
        case valetRequest
        case loadBarcodeModel
    }

    private let endpoint: ParkingEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()

    weak var controller: CreateParkingControllerProtocol?
    private var choosenDate = Date()
    private var guests: [Guest] = []
    private var currentRequest = CreateParkingRequest.oneTimeRequest
    private var amountOfRequests = 0
    private var needError = false
    private var carNumber: String = ""
    private var carModel: String?
    private var entranceInt: Int = 0
    private var entranceString: String = Localization.localize("createPass.entrance.front")
    private var barcode: Barcode?
    private var currentBarcodeModel: BarcodeModel?
    private var isResidentPay: Bool = true
    private let passEndpoint = PassEndpoint()
    private let recentGuests: [Guest]

    init(
		endpoint: ParkingEndpoint,
		authService: LocalAuthService,
		recentGuests: [Guest],
		parking: Parking? = nil
	) {
        self.endpoint = endpoint
        self.authService = authService
        self.recentGuests = recentGuests
        addListener()
        loadBarcodeModel()
		if let parking = parking {
			guests.append(Guest(fullName: parking.name, phone: parking.phone))
		}
    }

    func openCalendar() {
        let calendarController = CalendarViewController(delegate: self, interval: false)
        let router = ModalRouter(source: self.controller, destination: calendarController, modalPresentationStyle: .popover, modalTransitionStyle: .coverVertical)
        router.route()
    }

    func needAddGuest() {
        let controller = AddGuestController(delegate: self, recentGuests: recentGuests)
        self.controller?.present(module: controller)
    }

    func createParking(type: ParkingType, carNumber: String, carModel: String?, isResidentPay: Bool) {
		self.needError = false
		self.carNumber = carNumber
		self.carModel = carModel
		self.isResidentPay = isResidentPay
		chooseBarcodeModel()
		switch type {
			case .onetime:
				if self.guests.isEmpty {
					self.showEmptyDataError()
					return
				}
				for guest in self.guests {
					self.createOneTimeParking(name: guest.fullName, phone: guest.removePhoneFormat)
				}
			default:
				return
		}
    }

    func showGuestsError() {
        let assembly = InfoAssembly(title: Localization.localize("createParking.addGuest.limit.title"), subtitle: Localization.localize("createParking.addGuest.limit.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    func showEmptyDataError() {
        let assembly = InfoAssembly(title: Localization.localize("createParking.noData.title"), subtitle: Localization.localize("createParking.noData.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    func guestDidDelete(index: Int) {
        guests.remove(at: index)
    }
    
    func choosenPayer(isResident: Bool) {
        self.isResidentPay = isResident
    }
    
    func choosenEntrance(entrance: Entrance) {
        entranceInt = entrance.rawValue
        entranceString = entrance.localizedName
    }

    func showInfo() {
        ModalRouter(source: controller, destination: WebViewController(stringURL: WebViewInfoLinksConstants.parkInfoLink), modalPresentationStyle: .popover).route()
        //ModalRouter(source: controller, destination: ParkingInfoController(), modalPresentationStyle: .popover).route()
        //remove after
        chooseBarcodeModel()
    }
}

extension CreateParkingPresenter: CalendarViewControllerDelegate {
    func choosenDate(date: Date) {
        self.choosenDate = date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(identifier: "UTC")
        self.controller?.setChoosenDate(date: formatter.string(from: date))
    }

    func choosenInterval(start: Date, end: Date) {
        /*self.startDate = start

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let startDay = formatter.string(from: start)
        let fixEndDate = fixLastDateFromLibrary(end)
        self.endDate = fixEndDate
        let endDay = formatter.string(from: fixEndDate)
        self.controller?.setChoosenInterval(interval: "\(startDay) - \(endDay)")*/
    }

    // MARK: - Private API

    private func createOneTimeParking(name: String, phone: String) {
        self.currentRequest = .oneTimeRequest
        self.amountOfRequests = self.guests.count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.string(from: choosenDate)
        guard let token = self.authService.token?.accessToken else {
			self.controller?.loadingDone()
			return
		}

		guard let room = self.authService.room else {
			self.showEmptyDataError()
			self.controller?.loadingDone()
			return
		}
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createOneTimeParkingIssue(
                    companyID: self.barcode?.companyID ?? "",
                    barcodeModel: self.currentBarcodeModel?.id ?? "",
                    room: room.id,
                    carNumber: self.carNumber,
                    carModel: self.carModel,
                    guestName: name,
                    guestPhone: phone,
                    date: date,
                    token: accessToken
                )
            },
            doneCompletion: { _ in
                self.controller?.loadingDone()
                self.showSuccessInfo()
                self.controller?.dismissController()
				NotificationCenter.default.post(.parkingListReloadRequested)
            },
            errorCompletion: { error in
                self.controller?.loadingDone()
                self.amountOfRequests -= 1
                print("ERROR WHILE CREATE ONETIME PARKING: \(error.localizedDescription)")
                self.needError = true
                if self.amountOfRequests == 0 {
                    self.updateGuests()
                    self.showRequestError()
                }
            }
        )
    }

    private func loadBarcodeModel() {
        currentRequest = .loadBarcodeModel
        guard let token = self.authService.token?.accessToken else {
			return
		}

		guard let room = self.authService.room else {
			return
		}
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getBarcodeModel(companyName: room.number, token: accessToken)
            },
            doneCompletion: { barcode in
                self.barcode = barcode
            },
            errorCompletion: { error in
                print("ERROR WHILE LOAD BARCODEMODEL: \(error.localizedDescription)")
            }
        )
    }

    /*
    private func createPass(for guest: Guest) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateFrom = dateFormatter.string(from: choosenDate)
        let dateTo = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: choosenDate) ?? Date())
        guard let token = self.authService.token?.accessToken else { return }
        #if DEBUG
        guard let room = self.authService.user?.defaultRoom else { return }
        #else
        guard let room = self.authService.apartment else { return }
        #endif
        DispatchQueue.global(qos: .userInitiated).promise {
            self.passEndpoint.createOneTimePass(
                room: String(room.id),
                token: token,
                name: guest.name,
                surname: guest.surname,
                secondName: guest.patronymic,
                phone: guest.removePhoneFormat,
                dateFrom: dateFrom,
                dateTo: dateTo,
                role: "guest",
                isService: self.entranceInt == 1 ? true : false
            ).result
        }.done { _ in
            self.controller?.dismissController()
        }.catch { error in
            print("ERROR WHILE CREATE ONETIME PASS: \(error.localizedDescription)")
        }
    }
    */

    private func getIndexForPhone(_ phone: String) -> Int? {
        for guest in guests {
            if guest.removePhoneFormat == phone {
                return guests.firstIndex(of: guest)
            }
        }
        return nil
    }

    private func updateGuests() {
        self.controller?.updateGuests(self.guests)
    }

    private func showRequestError() {
        let assembly = InfoAssembly(title: Localization.localize("createParking.createOrder.error.title"), subtitle: Localization.localize("createParking.createOrder.error.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showSuccessInfo() {
        let assembly = InfoAssembly(title: Localization.localize("createParking.createOrder.success.title"), subtitle: nil, delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func chooseBarcodeModel() {
        guard let barcode = self.barcode else {
            return
        }

		if isResidentPay {
			if entranceInt == 0 {
				self.currentBarcodeModel = barcode.models.first { $0.name == BarCodeName.CENTRAL_ENTRANCE_RESIDENT_PAY }
			} else {
				self.currentBarcodeModel = barcode.models.first { $0.name == BarCodeName.SERVICE_ENTRANCE_RESIDENT_PAY }
			}
		} else {
			if entranceInt == 0 {
				self.currentBarcodeModel = barcode.models.first { $0.name == BarCodeName.CENTRAL_ENTRANCE_GUEST_PAY }
			} else {
				self.currentBarcodeModel = barcode.models.first { $0.name == BarCodeName.SERVICE_ENTRANCE_GUEST_PAY }
			}
		}
    }
}

extension CreateParkingPresenter: AddGuestControllerDelegate {
    func guestAdded(_ guest: Guest) {
        guests.append(guest)
        self.controller?.guestDidAdd(guest)
    }
}

extension CreateParkingPresenter {
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
