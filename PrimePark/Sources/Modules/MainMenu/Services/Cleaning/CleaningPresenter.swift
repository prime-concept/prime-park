import UIKit

protocol CleaningPresenterProtocol {
    func callCleaning(descriptionText: String?)
    func isNowDate(isNow: Bool)
    func openCalendar()
    func openTimePicker(forStart: Bool)
    func openChooseType()
    func setTime(time: String, forStart: Bool)
    func setChoosenType(type: String)
    func validateTime(time: Date, isStart: Bool)
}

final class CleaningPresenter: CleaningPresenterProtocol {
    private let endpoint: IssuesEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()
    
    weak var controller: CleaningControllerProtocol?

    private var isNow: Bool = true
    private var choosenDate = Date()
    private var startTime = "13:00"
    private var endTime = "16:00"
    private var type: String = Localization.localize("cleaning.serviceType.springСleaning")
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

        text += "\(Localization.localize("service.serviceName")): \(Localization.localize("cleaning.title"))\r\n"
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

    func callCleaning(descriptionText: String?) {
        self.descriptionText = descriptionText
        let text = createServiceDescription(descriptionText: descriptionText)
        guard let type = IssuesTypeService.shared.getCleaningType(),
        let room = self.authService.apartment,
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
                //let executeTime = Date().timeIntervalSince(responseDate)
                //print(executeTime)
                self.showSuccessAlert()
            },
            errorCompletion: { error in
                print("ERROR WHILE CALL CLEANING: \(error.localizedDescription)")
                self.showErrorAlert()
            }
        )
    }

    func isNowDate(isNow: Bool) {
        self.isNow = isNow
        let date = changeDate(startTimeStr: startTime, endTimeStr: endTime, date: choosenDate.dateWithCurrentTimeZone())
        startTime = date.startTimeStr ?? ""
        endTime = date.endTimeStr ?? ""
        controller?.setChoosenTime(fromTime: date.startTimeStr, beforeTime: date.endTimeStr)
    }

    func openCalendar() {
        let calendarController = CalendarViewController(delegate: self, maxDate: 14)
        let router = ModalRouter(source: self.controller, destination: calendarController, modalPresentationStyle: .popover, modalTransitionStyle: .coverVertical)
        router.route()
    }

    func openTimePicker(forStart: Bool) {
        self.isStartTimePicker = forStart
        let date = Date.createDateWith(time: !forStart ? startTime : endTime)
        let currentTime = Date.createDateWith(time: forStart ? startTime : endTime)
        let timePickerController = TimePickerViewController(
            delegate: self,
            title: Localization.localize(forStart ? "dryCleaning.chooseFromTime.title" : "dryCleaning.chooseBeforeTime.title"),
            date: date,
            isStartTime: !forStart,
            currentTime: currentTime,
            needCheckMinDate: Date.compareDays(firstDate: self.choosenDate.dateWithCurrentTimeZone(), secondDate: Date()) == .orderedSame
        )
        timePickerController.transitioningDelegate = transition
        let router = ModalRouter(source: self.controller, destination: timePickerController, modalPresentationStyle: .custom, modalTransitionStyle: .coverVertical)
        router.route()
    }

    func openChooseType() {
        let actionSheetController = ActionSheetController(delegate: self)
        actionSheetController.transitioningDelegate = transition
        actionSheetController.addActions([
            Localization.localize("cleaning.serviceType.springСleaning"),
            Localization.localize("cleaning.serviceType.cleaningAfterRenovation"),
            Localization.localize("cleaning.serviceType.maintenanceCleaning"),
            Localization.localize("cleaning.serviceType.windowCleaning"),
            Localization.localize("cleaning.serviceType.cleaningOther")
        ])
        let router = ModalRouter(source: self.controller, destination: actionSheetController, modalPresentationStyle: .custom, modalTransitionStyle: .coverVertical)
        router.route()
    }

    func setTime(time: String, forStart: Bool) {
        if forStart {
            self.startTime = time
        } else {
            self.endTime = time
        }
    }

    func setChoosenType(type: String) {
        self.type = type
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
        
        if beforeTime.timeIntervalSince(startTime) <= 1800 {
            beforeTime = startTime.addingTimeInterval(1800)
            self.endTime = dateFormatter.string(from: beforeTime)
            self.controller?.setChoosenTime(fromTime: nil, beforeTime: self.endTime)
        }
    }
    
    // MARK: - Private API

    private func refreshToken(_ token: String, username: String) {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.endpoint.refreshToken(token, username: username).result
        }.done { [weak self] token in
            self?.authService.updateToken(accessToken: token)
            self?.callCleaning(descriptionText: self?.descriptionText)
        }.catch { error in
            //MetricService.shared.reportErrorRefreshTokenEvent(error)
            
            print("ERROR WHILE ACCESS TOKEN REFRESH: \(error.localizedDescription)")
        }
    }
}
// swiftlint:disable trailing_whitespace
extension CleaningPresenter {
    
    // MARK: - Alerts
    
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
    
    // MARK: - Converter
}

extension CleaningPresenter: CalendarViewControllerDelegate {
    func choosenDate(date: Date) {
        self.choosenDate = date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        self.controller?.setChoosenDate(date: formatter.string(from: date))
    }

    func choosenInterval(start: Date, end: Date) {
    }
}

extension CleaningPresenter: TimePickerViewControllerDelegate, TimePickerFromBeforeProtocol {
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

extension CleaningPresenter: ActionSheetControllerDelegate {
    func choosenItem(index: Int) {
        /*self.type = index
        self.controller?.setChoosenType(type: index)*/
    }
}

extension CleaningPresenter: InfoControllerProtocol {
    func controllerDidClose() {
    }
}
