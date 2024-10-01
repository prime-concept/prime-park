import Foundation

protocol DryCleaningPresenterProtocol {
    func callDryCleaning(descriptionText: String?)
    func isNowDate(isNow: Bool)
    func openCalendar()
    func openTimePicker(forStart: Bool)
    func openChooseType()
    func setTime(time: String, forStart: Bool)
    func setChoosenType(type: String)
    func validateTime(time: Date, isStart: Bool)
}

final class DryCleaningPresenter: DryCleaningPresenterProtocol {
    private let endpoint: IssuesEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()

    weak var controller: DryCleaningViewProtocol?

    private var isNow: Bool = true
    private var choosenDate = Date()
    private var startTime = "13:00"
    private var endTime = "14:00"
    private var type: String = Localization.localize("dryCleaning.serviceType.dryCleaningClothes")
    private var isStartTimePicker: Bool = true
    private let transition = PanelTransition()
    private var descriptionText: String?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter
    }()

    init(endpoint: IssuesEndpoint, authService: LocalAuthService) {
        self.endpoint = endpoint
        self.authService = authService
    }

    private func createServiceDescription(descriptionText: String?) -> String {
        var text = ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        text += "\(Localization.localize("service.serviceName")): \(Localization.localize("dryCleaning.title"))\r\n"
        text += "\(Localization.localize("service.serviceType")): \(String(describing: type))\r\n"
        if let desText = descriptionText, !desText.isEmpty {
            text += "\(Localization.localize("service.serviceDescription")): \(String(describing: desText))\r\n"
        }
        if isNow {
            text += "\(Localization.localize("service.serviceDate")): \(Localization.localize("dryCleaning.serviceDate.buttonTitle.now"))\r\n"
        } else {
            text += "\(Localization.localize("service.serviceDate")): "
            text += dateFormatter.string(from: choosenDate)
            text += "\r\n"
            text += "\(Localization.localize("service.serviceTimeInterval")): \(String(describing: startTime))-\(String(describing: endTime))"
        }
        return text
    }

    func callDryCleaning(descriptionText: String?) {
        self.descriptionText = descriptionText
        let text = createServiceDescription(descriptionText: descriptionText)
        guard let type = IssuesTypeService.shared.getDrycleaningType(),
        let room = self.authService.user?.parcingRooms[0],
        let token = self.authService.token?.accessToken
        else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createIssue(
                    room: room.id,
                    text: text,
                    type: type,
                    token: accessToken
                )
            },
            doneCompletion: { _ in
                self.showSuccessAlert()
            },
            errorCompletion: { error in
                print("ERROR WHILE CALL DRY CLEANING: \(error.localizedDescription)")
                self.showErrorAlert()
            }
        )
    }

    func isNowDate(isNow: Bool) {
        self.isNow = isNow
        self.controller?.setChoosenTime(fromTime: self.startTime, beforeTime: self.endTime)
    }

    func openCalendar() {
        let calendarController = CalendarViewController(delegate: self, maxDate: 14)
        let router = ModalRouter(source: self.controller, destination: calendarController, modalPresentationStyle: .popover, modalTransitionStyle: .coverVertical)
        router.route()
    }

    func openTimePicker(forStart: Bool) {
        self.isStartTimePicker = forStart
        let date = Date.createDateWith(time: forStart ? startTime : endTime)
        let currentTime = Date.createDateWith(time: forStart ? startTime : endTime)
        let timePickerController = TimePickerViewController(
            delegate: self,
            title: Localization.localize(forStart ? "dryCleaning.chooseFromTime.title" : "dryCleaning.chooseBeforeTime.title"),
            date: date,
            isStartTime: forStart,
            currentTime: currentTime,
            needCheckMinDate: Date.compareDays(firstDate: self.choosenDate, secondDate: Date()) == .orderedSame
        )
        timePickerController.transitioningDelegate = transition
        let router = ModalRouter(source: self.controller, destination: timePickerController, modalPresentationStyle: .custom, modalTransitionStyle: .coverVertical)
        router.route()
    }

    func setTime(time: String, forStart: Bool) {
        if forStart {
            self.startTime = time
        } else {
            self.endTime = time
        }
    }
    
    func validateTime(time: Date, isStart: Bool) {
        let time = dateFormatter.string(from: time)
        if isStart {
            self.startTime = time
            self.controller?.setChoosenTime(fromTime: time, beforeTime: nil)
        } else {
            self.endTime = time
            self.controller?.setChoosenTime(fromTime: nil, beforeTime: time)
        }
        self.checkTimeInterval()
    }
    
    private func checkTimeInterval() {
        guard let startTime = dateFormatter.date(from: self.startTime),
              var beforeTime = dateFormatter.date(from: self.endTime) else { return }
        
        if beforeTime.timeIntervalSince(startTime) <= 3600 {
            beforeTime = startTime.addingTimeInterval(3600)
            self.endTime = dateFormatter.string(from: beforeTime)
            self.controller?.setChoosenTime(fromTime: nil, beforeTime: self.endTime)
        }
    }

    func setChoosenType(type: String) {
        self.type = type
    }

    func openChooseType() {
        let actionSheetController = ActionSheetController(delegate: self)
        actionSheetController.transitioningDelegate = transition
        actionSheetController.addActions([
            Localization.localize("dryCleaning.serviceType.dryCleaningClothes"),
            Localization.localize("dryCleaning.serviceType.dryCleaningFurniture"),
            Localization.localize("dryCleaning.serviceType.dryCleaningCarpet"),
            Localization.localize("dryCleaning.serviceType.dryCleaningCurtain"),
            Localization.localize("dryCleaning.serviceType.dryCleaningOther")
        ])
        let router = ModalRouter(source: self.controller, destination: actionSheetController, modalPresentationStyle: .custom, modalTransitionStyle: .coverVertical)
        router.route()
    }

    // MARK: - Private API

    private func showSuccessAlert() {
        let assembly = InfoAssembly(title: Localization.localize("dryCleaning.popup.title"), subtitle: nil, delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showErrorAlert() {
        let assembly = InfoAssembly(title: Localization.localize("service.orderService.error.title"), subtitle: Localization.localize("service.orderService.error.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showTimeError() {
        let assembly = InfoAssembly(
            title: Localization.localize("service.chooseTime.error.title"),
            subtitle: Localization.localize("service.chooseTime.error.subtitle"),
            delegate: nil,
            status: .failure
        )
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }
}

extension DryCleaningPresenter: CalendarViewControllerDelegate {
    func choosenDate(date: Date) {
		let date = date + (-1).days
        self.choosenDate = date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(identifier: "UTC")
        self.controller?.setChoosenDate(date: formatter.string(from: date))
    }

    func choosenInterval(start: Date, end: Date) {
    }
}

extension DryCleaningPresenter: TimePickerViewControllerDelegate, TimePickerFromBeforeProtocol {
    func choosenTime(time: String) {
        let timeDate = Date.createDateWith(time: time, format: .HHmm)
        let startTimeDate = Date.createDateWith(time: startTime, format: .HHmm)
        if self.isStartTimePicker {
            if time > endTime {
                let fullDate = changeDate(startTimeStr: time, endTimeStr: endTime, date: choosenDate)
                self.controller?.setChoosenTime(fromTime: fullDate.startTimeStr, beforeTime: fullDate.endTimeStr)
                self.startTime = time
                self.endTime = fullDate.endTimeStr ?? String()
                return
            }
            self.controller?.setChoosenTime(fromTime: time, beforeTime: nil)
            self.startTime = time
        } else {
            print(startTimeDate.calcDiffInMin(timeDate))
            if startTimeDate.calcDiffInMin(timeDate) > -30 {
                showTimeError()
                return
            }
            self.controller?.setChoosenTime(fromTime: nil, beforeTime: time)
            self.endTime = time
        }
    }
}

extension DryCleaningPresenter: ActionSheetControllerDelegate {
    func choosenItem(index: Int) {
        /*self.type = index
        self.controller?.setChoosenType(type: index)*/
    }
}
