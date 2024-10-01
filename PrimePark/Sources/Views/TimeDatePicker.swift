import Foundation
import UIKit

class TimeDatePicker: UIDatePicker {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter
    }()
    
    init(minDate: String, maxDate: String) {
        super.init(frame: .zero)
        self.setup()
        self.maximumDate = dateFormatter.date(from: maxDate)
        self.minimumDate = dateFormatter.date(from: minDate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.datePickerMode = .time
        self.minuteInterval = 30
        if #available(iOS 13.4, *) {
            self.preferredDatePickerStyle = .wheels
        }
        self.backgroundColor = UIColor(red: 0.212, green: 0.212, blue: 0.212, alpha: 1)
        self.setValue(UIColor.white, forKeyPath: "textColor")
        self.timeZone = TimeZone(identifier: "GMT")
        self.locale = Locale(identifier: "ru_RU")
    }
    
    func updateMinTime(time: String) {
        self.minimumDate = dateFormatter.date(from: time)
    }
    
    func resetMinTime() {
        self.minimumDate = dateFormatter.date(from: "9:00")
    }
}
