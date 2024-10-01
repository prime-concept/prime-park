import UIKit

protocol CarWashCalendarViewProtocol: AnyObject {
    func updateDates(dates: [DaysModel])
    func updateTimeslots(slots: [TimeslotModel])
}

final class CarWashCalendarViewController: UIViewController {
    private let presenter: CarWashCalendarPresenterProtocol
    private lazy var calendarView = CarWashCalendarView()
        
    override func loadView() {
        view = calendarView
        calendarView.delegate = self
    }

    init(presenter: CarWashCalendarPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.generateNearestDatesViewModels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CarWashCalendarViewController: CarWashCalendarViewDelegate {
    func updateTime(index: Int) {
        self.presenter.setSelectedTime(index: index)
    }
    func updateDate(index: Int) {
        self.presenter.setSelectedDate(index: index)
    }
    func setChoosenDateAndTime() {
        self.presenter.confirmSelectedTimeslot()
        self.dismiss(animated: true)
    }
}

extension CarWashCalendarViewController: CarWashCalendarViewProtocol {
    func updateDates(dates: [DaysModel]) {
        self.calendarView.updateDates(dates: dates)
    }

    func updateTimeslots(slots: [TimeslotModel]) {
        self.calendarView.updateTimeslots(timeslots: slots)
    }
}
