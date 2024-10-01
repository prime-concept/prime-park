import UIKit
import FSCalendar

protocol CalendarViewDelegate: class {
    func didChoose(date: Date)
    func didChooseInterval(start: Date, end: Date)
}

final class CalendarView: UIView, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet weak var doneButton: LocalizableButton!

    private weak var calendarDelegate: CalendarViewDelegate?
    private var interval: Bool = false
    private var datesRange: [Date] = []
    var maxDate: Double = 14

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    private let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)

    // MARK: - Initialization

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    init(delegate: CalendarViewDelegate) {
        self.calendarDelegate = delegate
        super.init(frame: .zero)
    }

    // MARK: - Public API

    func commonInit() {
        calendar.delegate = self
        calendar.dataSource = self
        self.calendar.allowsMultipleSelection = interval
        self.calendar.appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesUpperCase]
        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        self.calendar.addGestureRecognizer(scopeGesture)
        self.calendar.scrollDirection = .vertical
        //Calendar default selection
        self.calendar.select(Date())
        if interval {
            self.calendar.select(Calendar.current.date(byAdding: .day, value: 1, to: Date()))
        }
        doneButton.isEnabled = true
        doneButton.backgroundColor = Palette.goldColor.withAlphaComponent(1)
        calendar.reloadData()
    }

    func addDelegate(delegate: CalendarViewDelegate) {
        self.calendarDelegate = delegate
    }

    func chooseInterval(_ needInterval: Bool) {
        self.interval = needInterval
    }

    // MARK: - Private API

    // swiftlint:disable force_unwrapping
    private func selectDatesRange(from: Date, to: Date) -> [Date] {
        if from > to { return [Date]() }
        var tempDate = from
        var array = [tempDate]
        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        return array
    }

    private func performDateDeselect(_ calendar: FSCalendar, date: Date) {
        let sorted = calendar.selectedDates.sorted { $0 < $1 }
        if let index = sorted.firstIndex(of: date) {
            let deselectDates = Array(sorted[index...])
            for day in deselectDates {
                calendar.deselect(day)
            }
        }
    }

    private func performDateSelection(_ calendar: FSCalendar) {
        let sorted = calendar.selectedDates.sorted { $0 < $1 }
        if let firstDate = sorted.first, let lastDate = sorted.last {
            let ranges = selectDatesRange(from: firstDate, to: lastDate)
            for day in ranges {
                calendar.select(day)
            }
        }
    }

    private func updateDoneButtonEnable() {
        if interval && (calendar.selectedDates.isEmpty || calendar.selectedDates.count == 1) {
            doneButton.isEnabled = false
            doneButton.backgroundColor = Palette.goldColor.withAlphaComponent(0.5)
            return
        }
        doneButton.isEnabled = true
        doneButton.backgroundColor = Palette.goldColor.withAlphaComponent(1)
    }

    // MARK: - Action

    @IBAction private func done(_ sender: Any) {
        if interval {
            var selectedDates = calendar.selectedDates.map { Calendar.current.date(byAdding: .day, value: 1, to: $0) ?? Date() }
            
            selectedDates.sort()
            
            if !selectedDates.isEmpty {
                self.calendarDelegate?.didChooseInterval(start: selectedDates[0], end: selectedDates[selectedDates.count - 1])
            }
        } else {
            guard let selectedDate = calendar.selectedDate else { return }
            
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            
            let dayUp = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
            
            let selectedDateFixed = dayUp//Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
            self.calendarDelegate?.didChoose(date: selectedDateFixed)
        }
    }

    // MARK: - FSCalendarDataSource

    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return nil
    }

    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return nil
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date().addingTimeInterval(60 * 60 * 24 * maxDate)
    }

    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }

    // MARK: - FSCalendarDelegate

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("Change page to \(self.dateFormatter.string(from: calendar.currentPage))")
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("calendar did select date \(self.dateFormatter.string(from: date))")
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        performDateSelection(calendar)
        updateDoneButtonEnable()
    }

    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        performDateDeselect(calendar, date: date)
        updateDoneButtonEnable()
        return true
    }

    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return date.compare(Date.startOfCurrentDate()) == .orderedDescending || date.compare(Date.startOfCurrentDate()) == .orderedSame
    }

    /*func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        print("Calendar did change bounds.")
        //self.calendarHeightConstraint.constant = bounds.height
        //self.view.layoutIfNeeded()
    }*/
}
