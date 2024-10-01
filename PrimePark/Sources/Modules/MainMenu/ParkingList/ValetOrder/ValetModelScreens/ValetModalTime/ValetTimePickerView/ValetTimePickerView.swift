//
//  ValetTimePickerView.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 06.05.2021.
//
import Foundation

protocol ValetTimePickerViewDelegate: AnyObject, ModalRouterSourceProtocol {
    func setChoosenTime(date: Date)
}

final class ValetTimePickerView: UIView {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate: ValetTimePickerViewDelegate?
    
    func commonInit(delegate: ValetTimePickerViewDelegate? = nil) {
        self.delegate = delegate
        let minDate = Date() + .minute(9)
        datePicker.minimumDate = minDate
        datePicker.setDate(minDate, animated: true)
        //delegate?.setChoosenTime(date: minDate.dateWithCurrentTimeZone())
        datePicker.addTarget(self, action: #selector(timeDidChange), for: .valueChanged)
    }
    
    @objc
    func timeDidChange() {
        //delegate?.setChoosenTime(date: datePicker.date.dateWithCurrentTimeZone())
    }
    
    @IBAction func tapDone(_ sender: Any) {
        delegate?.dismiss {
            self.delegate?.setChoosenTime(date: self.datePicker.date.dateWithCurrentTimeZone())
        }
    }
}
