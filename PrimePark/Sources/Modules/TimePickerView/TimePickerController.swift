import UIKit

protocol TimePickerViewControllerDelegate: class {
    func choosenTime(time: String)
}

final class TimePickerViewController: UIViewController {
    private lazy var timePickerView: TimePickerView = {
        let view = Bundle.main.loadNibNamed("TimePickerView", owner: nil, options: nil)?.first as? TimePickerView ?? TimePickerView(delegate: self)
        return view
    }()

    private weak var delegate: TimePickerViewControllerDelegate?
    private var pickerTitle: String = ""
    private let date: Date
    private let isStartTime: Bool
    private let currentTime: Date
    private let needCheckMinDate: Bool

    init(delegate: TimePickerViewControllerDelegate, title: String, date: Date, isStartTime: Bool, currentTime: Date, needCheckMinDate: Bool) {
        self.delegate = delegate
        self.pickerTitle = title
        self.date = date
        self.isStartTime = isStartTime
        self.currentTime = currentTime
        self.needCheckMinDate = needCheckMinDate
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = timePickerView
        timePickerView.addDelegate(delegate: self)
        timePickerView.setPickerTitle(title: self.pickerTitle)
        timePickerView.setDate(date, forStart: isStartTime, needCheckMinDate: needCheckMinDate)
        timePickerView.setCurrentTime(currentTime, isStart: isStartTime)
        timePickerView.commonInit()
        timePickerView.setupTimePicker()
    }
}

extension TimePickerViewController: TimePickerViewDelegate {
    func didChoose(time: String) {
        self.dismiss(animated: true) {
            self.delegate?.choosenTime(time: time)
        }
    }
}

protocol TimePickerFromBeforeProtocol {
    func changeDate(startTimeStr: String, endTimeStr: String, date: Date) -> (startTimeStr: String?, endTimeStr: String?, date: String?)
}

extension TimePickerFromBeforeProtocol {
    func changeDate(startTimeStr: String, endTimeStr: String, date: Date) -> (startTimeStr: String?, endTimeStr: String?, date: String?) {
        //formatters
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone(identifier: "GMT")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        //
        let currentTime = Date().dateWithCurrentTimeZone()
        let choosenTime = Date.createDateWith(time: startTimeStr)
        if Date.compareDays(firstDate: date, secondDate: currentTime) == .orderedSame {
            //current day
            if Date.compareTime(firstTime: timeFormatter.date(from: "13:00") ?? Date(), secondTime: currentTime) == .orderedDescending && startTimeStr == "13:00" {
                return (
                    startTimeStr,
                    endTimeStr,
                    dateFormatter.string(from: date)
                )
            }
            if Date.compareTime(firstTime: choosenTime, secondTime: currentTime) == .orderedDescending { //choosenTime > currentTime
                guard let updatedChoosenTime = Calendar.current.date(byAdding: .minute, value: 30, to: choosenTime) else { return (nil, nil, nil) }
                return (
                    timeFormatter.string(from: choosenTime),
                    timeFormatter.string(from: updatedChoosenTime),
                    dateFormatter.string(from: date)
                )
            } else {
                guard let updatedCurrentTime = Calendar.current.date(byAdding: .minute, value: 30, to: currentTime) else { return (nil, nil, nil) }
                return (
                    timeFormatter.string(from: currentTime),
                    timeFormatter.string(from: updatedCurrentTime),
                    dateFormatter.string(from: date)
                    )
            }
        }
        return (
            startTimeStr,
            endTimeStr,
            dateFormatter.string(from: date)
        )
    }
}
