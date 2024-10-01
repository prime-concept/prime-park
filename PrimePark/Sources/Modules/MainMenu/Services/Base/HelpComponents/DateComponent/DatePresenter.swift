//
//  DatePresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.03.2021.
//
//swiftlint:disable all
import Foundation

final class DateComponentPresenter {
    weak var view: DateComponentProtocol?
    private var choosenDate = Date()
}

extension DateComponentPresenter: DateComponentDelegate {
    func openCalendar() {
        let calendarController = CalendarViewController(delegate: self, maxDate: 14)
        let router = ModalRouter(source: view?.presenterController, destination: calendarController, modalPresentationStyle: .popover, modalTransitionStyle: .coverVertical)
        router.route()
    }
}

extension DateComponentPresenter: CalendarViewControllerDelegate {
    func choosenDate(date: Date) {
        self.choosenDate = date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        view?.setChoosenDate(date: formatter.string(from: date))
    }
}
