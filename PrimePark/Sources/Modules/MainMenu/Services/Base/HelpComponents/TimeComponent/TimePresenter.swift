//
//  TimePresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.03.2021.
//
//swiftlint:disable all
import Foundation

final class TimeComponentPresenter: CalendarViewControllerDelegate {
    
    private var isNow: Bool = true
    private var choosenDate = Date().dateWithCurrentTimeZone()
    private var startTime = "13:00"
    private var endTime = "16:00"
    private var isStartTimePicker: Bool = true
    private let transition = PanelTransition()
    
    weak var view: TimeComponentProtocol?
    
    func choosenDate(date: Date) {
    }
    
    func choosenInterval(start: Date, end: Date) {
    }
    
    
}

extension TimeComponentPresenter: TimeComponentDelegate, TimePickerViewControllerDelegate, TimePickerFromBeforeProtocol {
    func choosenTime(time: String) {
        let timeDate = Date.createDateWith(time: time, format: .HHmm)
        let startTimeDate = Date.createDateWith(time: startTime, format: .HHmm)
        if self.isStartTimePicker {
            if time > endTime {
                let fullDate = changeDate(startTimeStr: time, endTimeStr: endTime, date: choosenDate)
                self.view?.setChoosenTime(fromTime: fullDate.startTimeStr, beforeTime: fullDate.endTimeStr)
                self.startTime = time
                self.endTime = fullDate.endTimeStr ?? String()
                return
            }
            self.view?.setChoosenTime(fromTime: time, beforeTime: nil)
            self.startTime = time
        } else {
            print(startTimeDate.calcDiffInMin(timeDate))
            if startTimeDate.calcDiffInMin(timeDate) > -30 {
                showTimeError()
                return
            }
            self.view?.setChoosenTime(fromTime: nil, beforeTime: time)
            self.endTime = time
        }
    }
    
    func openTimeController(forStart: Bool) {
        self.isStartTimePicker = forStart
        let date = Date.createDateWith(time: !forStart ? startTime : endTime)
        let currentTime = Date.createDateWith(time: forStart ? startTime : endTime)
        let timePickerController = TimePickerViewController(
            delegate: self,
            title: Localization.localize(forStart ? "dryCleaning.chooseFromTime.title" : "dryCleaning.chooseBeforeTime.title"),
            date: date,
            isStartTime: !forStart,
            currentTime: currentTime,
            needCheckMinDate: Date.compareDays(firstDate: self.choosenDate.dateWithCurrentTimeZone(), secondDate: Date()) == .orderedSame
        )
        timePickerController.transitioningDelegate = transition
        let router = ModalRouter(source: self.view?.presenterController, destination: timePickerController, modalPresentationStyle: .custom, modalTransitionStyle: .coverVertical)
        router.route()
    }
}

extension TimeComponentPresenter {
    private func showTimeError() {
        let assembly = InfoAssembly(
            title: Localization.localize("service.chooseTime.error.title"),
            subtitle: Localization.localize("service.chooseTime.error.subtitle"),
            delegate: nil,
            status: .failure
        )
        let router = ModalRouter(source: self.view?.presenterController, destination: assembly.make())
        router.route()
    }
}
