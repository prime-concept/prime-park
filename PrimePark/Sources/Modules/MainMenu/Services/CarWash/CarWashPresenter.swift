import UIKit

protocol CarWashPresenterProtocol {
    func getCarWashHistory()
    func getCarWashServices() -> [ServicesViewModel]
    func uploadCarWashServices()
    func openRecordDetail(index: Int)
    func updateSelectedTimeslot(timeslot: Timeslot, dayIndex: Int, timeIndex: Int)
    func updateSelectedService(index: Int)
    func getSelectedDateAndTime() -> (Int, Int)
    func setComment(comment: String)
    func createCarWashRequest()
}

final class CarWashPresenter: CarWashPresenterProtocol {
    private let endpoint: CarWashEndpoint
    private let authService: LocalAuthService
    private let networkService = NetworkService()

    weak var controller: CarWashViewProtocol?

    private var choosenDate = Date()
    private let transition = PanelTransition()
    private var historyRecords: [HistoryRecordViewModel] = []
    private var dayIndex: Int = 0
    private var timeIndex: Int = 0
    private var selectedServiceIndex: Int = 0
    private var selectedTimeslot: Timeslot?
    private var services: [ServicesViewModel] = []
    private var commet: String = localizedWith("carWash.driver.comePersonally")
    

    init(endpoint: CarWashEndpoint, authService: LocalAuthService) {
        self.endpoint = endpoint
        self.authService = authService
    }

    func getCarWashHistory() {
        guard let token = LocalAuthService.shared.token?.accessToken,
        let user = LocalAuthService.shared.user else { return }
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getFilteredHistory(token: accessToken, phone: user.phone)
            },
            doneCompletion: { result in
                self.historyRecords = result.data.records.map(HistoryRecordViewModel.makeAsViewModel(from:))
                self.controller?.updateHistoryRecords(records: self.historyRecords)
            },
            errorCompletion: { error in
                print("ERROR: \(error.localizedDescription)")
            }
        )
    }

    func createCarWashRequest() {
        guard let token = LocalAuthService.shared.token?.accessToken,
              let user = LocalAuthService.shared.user,
              let timeslot = self.selectedTimeslot
        else {
            self.showUnfilledAlert()
            return
        }
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.createCarWashRequest(
                    token: token,
                    comment: self.commet,
                    timeslot: timeslot,
                    service: self.services[self.selectedServiceIndex],
                    user: user
                )
            },
            doneCompletion: { result in
                if result.success {
                    self.showSuccessAlert()
                } else {
                    self.showErrorAlert()
                }
            },
            errorCompletion: { error in
                print("ERROR: \(error.localizedDescription)")
                self.showErrorAlert()
            }
        )
    }

    func uploadCarWashServices() {
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getServices(token: accessToken)
            },
            doneCompletion: { result in
                self.services = result.data.map(ServicesViewModel.makeAsViewModel(from:))
                if !self.services.isEmpty {
                    self.services[self.selectedServiceIndex].isSelected = true
                }
                self.controller?.setDefaultServiceType(
                    type: self.services[self.selectedServiceIndex].title
                )
            },
            errorCompletion: { error in
                print("ERROR: \(error.localizedDescription)")
            }
        )
    }

    func openRecordDetail(index: Int) {
        let historyController = CarWashHistoryViewController(recordViewModel: self.historyRecords[index])
        let router = ModalRouter(source: self.controller, destination: historyController, modalPresentationStyle: .popover, modalTransitionStyle: .coverVertical)
        router.route()
    }

    func getCarWashServices() -> [ServicesViewModel] {
        self.services
    }

    func updateSelectedService(index: Int) {
        self.services[self.selectedServiceIndex].isSelected = false
        self.selectedServiceIndex = index
        self.services[self.selectedServiceIndex].isSelected = true
    }

    func getSelectedDateAndTime() -> (Int, Int) {
        return (self.dayIndex, self.timeIndex)
    }

    func setComment(comment: String) {
        self.commet = comment
    }

    // MARK: - Private API

    private func showSuccessAlert() {
        let assembly = InfoAssembly(title: Localization.localize("carWash.alert.success.title"), subtitle: Localization.localize("carWash.alert.success.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showErrorAlert() {
        let assembly = InfoAssembly(title: Localization.localize("carWash.alert.error.title"), subtitle: Localization.localize("carWash.alert.error.subtitle"), delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    private func showUnfilledAlert() {
        let assembly = InfoAssembly(title: Localization.localize("carWash.unfilled.error.title"), subtitle: nil, delegate: nil)
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    func updateSelectedTimeslot(timeslot: Timeslot, dayIndex: Int, timeIndex: Int) {
        self.dayIndex = dayIndex
        self.timeIndex = timeIndex
        self.selectedTimeslot = timeslot
    }
}

extension CarWashPresenter: CalendarViewControllerDelegate {
    func choosenDate(date: Date) {
    }

    func choosenInterval(start: Date, end: Date) {
    }
}
