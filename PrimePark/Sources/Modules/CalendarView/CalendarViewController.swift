import UIKit
import  FSCalendar

protocol CalendarViewControllerDelegate: class {
    func choosenDate(date: Date)
    func choosenInterval(start: Date, end: Date)
}

extension CalendarViewControllerDelegate {
    func choosenInterval(start: Date, end: Date) {}
}

final class CalendarViewController: UIViewController {
    private lazy var calendarView: CalendarView = {
        let view = Bundle.main.loadNibNamed("CalendarView", owner: nil, options: nil)?.first as? CalendarView ?? CalendarView(delegate: self)
        return view
    }()

    private weak var delegate: CalendarViewControllerDelegate?
    private let isInterval: Bool
    private var maxDate: Double

    init(delegate: CalendarViewControllerDelegate, maxDate: Double = 365) {
        self.delegate = delegate
        self.isInterval = false
        self.maxDate = maxDate
        super.init(nibName: nil, bundle: nil)
    }

    init(delegate: CalendarViewControllerDelegate, interval: Bool, maxDate: Double = 365) {
        self.delegate = delegate
        self.isInterval = interval
        self.maxDate = maxDate
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = calendarView
        calendarView.addDelegate(delegate: self)
        calendarView.chooseInterval(isInterval)
        calendarView.maxDate = maxDate
        calendarView.commonInit()
    }
}
//swiftlint:disable force_unwrapping
extension CalendarViewController: CalendarViewDelegate {
    func didChoose(date: Date) {
        print("didChoose \(date)")
        self.delegate?.choosenDate(date: date)
        self.dismiss(animated: true, completion: nil)
    }

    func didChooseInterval(start: Date, end: Date) {
        print("didChoose \(start) \(end)")
        self.delegate?.choosenInterval(start: start, end: end)
        self.dismiss(animated: true, completion: nil)
    }
}
