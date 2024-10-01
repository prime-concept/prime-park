//
//  ValetModalTimeController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//
// swiftlint:disable trailing_whitespace force_unwrapping
import UIKit

protocol ValetModalTimeControllerProtocol: class {
    func transitContent(content: [ValetTimeModel])
}

class ValetModalTimeController: PannableViewController, ValetModalTimeControllerProtocol, ValetTimeHolder {
    
    private lazy var valetModalTimeView: ValetModalTimeView = {
        return Bundle.main.loadNibNamed("ValetModalTimeView", owner: nil, options: nil)?.first as? ValetModalTimeView ?? ValetModalTimeView()
    }()
    
    var presenter: ValetModalTimePresenterProtocol
    
    private let panelTransition = PanelTransition()
    
    var choosenTime = Date().dateWithCurrentTimeZone() + .minute(9) {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            print(choosenTime)
            valetModalTimeView.timeLabel.text = formatter.string(from: choosenTime)
        }
    }
    
    var choosenDate = Date().dateWithCurrentTimeZone()
    
    init(presenter: ValetModalTimePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = valetModalTimeView
        valetModalTimeView.commonInit(delegate: self)
    }
}

extension ValetModalTimeController: ValetModalTimeViewDelegate {
    func back() {
        let controller = ValetModalFirstAssembly(parketTicket: presenter.parkingTicket).make()
        panelTransition.isPresentedDismiss = true
        panelTransition.currentPresentation = .valetFirst
        controller.transitioningDelegate = panelTransition
        ModalRouter(source: self, destination: controller, modalPresentationStyle: .custom).route()
    }
    
    func chooseDay(date: Date) {
        choosenDate = date
    }
    
    func chooseTime() {
        let controller = ValetTimePickerAssembly(presenter: self).make()
        panelTransition.isPresentedDismiss = false
        panelTransition.currentPresentation = .valetTimePicker
        controller.transitioningDelegate = panelTransition
        ModalRouter(source: self, destination: controller, modalPresentationStyle: .custom).route()
    }
    
    func serveCar() {
        print(choosenTime)
        print(choosenDate)
        
        let interval = Date.formDiffDate(date: self.choosenDate, time: self.choosenTime)
        
        print(interval)
        
        dismiss {
            let controller = ValetTimerAssembly(
                parkingTicket: self.presenter.parkingTicket,
                state: .creating(interval)
            ).make()
            
            PushRouter(source: nil, destination: controller).route()
        }
    }
    
    func transitContent(content: [ValetTimeModel]) {
        valetModalTimeView.content = content
    }
}
