import UIKit

protocol TimePickerViewDelegate: class {
    func didChoose(time: String)
}

final class TimePickerView: UIView {

    @IBOutlet private weak var titleLabel: LocalizableLabel!
    @IBOutlet private weak var timePicker: UIDatePicker!

    private weak var timePickerDelegate: TimePickerViewDelegate?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter
    }()

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

    init(delegate: TimePickerViewDelegate) {
        self.timePickerDelegate = delegate
        super.init(frame: .zero)
    }

    // MARK: - Public API

    func commonInit() {
        timePicker.minuteInterval = 30
        timePicker.timeZone = TimeZone(identifier: "GMT")
    }

    func addDelegate(delegate: TimePickerViewDelegate) {
        self.timePickerDelegate = delegate
    }

    func setPickerTitle(title: String) {
        titleLabel.text = title
    }
    
    func setupTimePicker() {
        
        timePicker.minimumDate = dateFormatter.date(from: "\(Calendar.current.component(.hour, from: Date()) + 1):00")
        timePicker.maximumDate = dateFormatter.date(from: "21:00")
    }

    func setDate(_ date: Date, forStart: Bool, needCheckMinDate: Bool) {
        if forStart {
            if needCheckMinDate /*&& Date.compareTime(firstTime: date, secondTime: Date()) == .orderedAscending*/ {
                timePicker.minimumDate = Date().dateWithCurrentTimeZone()
            } else {
                timePicker.minimumDate = dateFormatter.date(from: "00:00")
            }
        } else {
            if needCheckMinDate {
                timePicker.minimumDate = Date().dateWithCurrentTimeZone()
            } else {
                timePicker.minimumDate = dateFormatter.date(from: "00:00")
            }
        }
    }

    func setCurrentTime(_ time: Date, isStart: Bool) {
        /*if Date.compareTime(firstTime: time, secondTime: Date()) == .orderedAscending {
            timePicker.date = Date().dateWithCurrentTimeZone()
            return
        }*/
        timePicker.date = time
        print(time)
    }

    // MARK: - Action

    @IBAction private func doneButton(_ sender: Any) {
        self.timePickerDelegate?.didChoose(time: dateFormatter.string(from: timePicker.date))
    }
}
