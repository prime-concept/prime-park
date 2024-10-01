import UIKit

final class CarWashCalendarAssembly: Assembly {
    private let selectedDate: Int
    private let selectedTime: Int
    private let onSelect: (Timeslot, Int, Int) -> Void
    
    init(selectedDate: Int = 0,  selectedTime: Int = 0, onSelect: @escaping (Timeslot, Int, Int) -> Void) {
        self.selectedDate = selectedDate
        self.selectedTime = selectedTime
        self.onSelect = onSelect
    }
    
    func make() -> UIViewController {
        let presenter = CarWashCalendarPresenter(
            selectedDate: self.selectedDate,
            selectedTime: self.selectedTime,
            onSelect: onSelect
        )
        let controller = CarWashCalendarViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
