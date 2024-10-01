import UIKit

protocol CarWashCalendarPresenterProtocol {
    func setSelectedDate(index: Int)
    func setSelectedTime(index: Int)
    func confirmSelectedTimeslot()
    func generateNearestDatesViewModels()
}

final class CarWashCalendarPresenter: CarWashCalendarPresenterProtocol {
    
    weak var controller: CarWashCalendarViewProtocol?

    private let networkService = NetworkService()
    private let endpoint = CarWashEndpoint()
    private let onSelect: ((Timeslot, Int, Int) -> Void)
    private var selectedDate: Int
    private var selectedTime: Int
    private var days: [DaysModel] = []
    private var timeslots: [TimeslotModel] = []

    init(
        selectedDate: Int,
        selectedTime: Int,
        onSelect: @escaping ((Timeslot, Int, Int) -> Void)
    ) {
        self.selectedDate = selectedDate
        self.selectedTime = selectedTime
        self.onSelect = onSelect
    }

    func generateNearestDatesViewModels() {
        var dates: [Date] = []
            
        let today = Date()
        let calendar = Calendar.current
            
        if let twoWeeksFromNow = calendar.date(byAdding: .day, value: 14, to: today) {
            var currentDate = today
                
            while currentDate <= twoWeeksFromNow {
                dates.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        self.days = dates.map(DaysModel.makeAsViewModel(from:))
        self.days[self.selectedDate].isSelected = true
        self.controller?.updateDates(dates: self.days)
        self.getTimeslots(date: self.days[selectedDate].date.string("yyyy-MM-dd'T'HH:mm:ss"))
    }

    func setSelectedDate(index: Int) {
        self.days[self.selectedDate].isSelected = false
        self.selectedDate = index
        self.days[self.selectedDate].isSelected = true
        self.controller?.updateDates(dates: self.days)
        self.selectedTime = 0
        self.getTimeslots(date: self.days[selectedDate].date.string("yyyy-MM-dd'T'HH:mm:ss"))
    }
        
    func setSelectedTime(index: Int) {
        self.timeslots[self.selectedTime].isSelected = false
        self.selectedTime = index
        self.timeslots[self.selectedTime].isSelected = true
        self.controller?.updateTimeslots(slots: self.timeslots)
    }
        
    func confirmSelectedTimeslot() {
        self.onSelect(self.timeslots[selectedTime].timeslot, self.selectedDate, self.selectedTime)
    }
    func getTimeslots(date: String) {
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        networkService.request(
            accessToken: token,
            requestCompletion: { accessToken in
                self.endpoint.getTimeslots(token: accessToken, date: date)
            },
            doneCompletion: { res in
                self.timeslots = res.data.map(TimeslotModel.makeAsViewModel(from:))
                if !self.timeslots.isEmpty {
                    self.timeslots[self.selectedTime].isSelected = true
                }
                self.controller?.updateTimeslots(slots: self.timeslots)
            },
            errorCompletion: { error in
                self.controller?.updateTimeslots(slots: [])
                print("ERROR WHILE CALL CLEANING: \(error.localizedDescription)")
            }
        )
    }
}

struct DaysModel {
    let date: Date
    var isSelected: Bool
}

extension DaysModel {
    static func makeAsViewModel(from date: Date) -> DaysModel {
        return DaysModel(
            date: date,
            isSelected: false
        )
    }
}

struct TimeslotModel {
    let timeslot: Timeslot
    var isSelected: Bool
}

extension TimeslotModel {
    static func makeAsViewModel(from timeslot: Timeslot) -> TimeslotModel {
        return TimeslotModel(
            timeslot: timeslot,
            isSelected: false
        )
    }
}

