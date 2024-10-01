//
//  ValetModalFirstController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 05.05.2021.
//
// swiftlint:disable trailing_whitespace
import UIKit

class ValetModalFirstController: PannableViewController {
    private lazy var valetModalViewFirst: ValetModalFirstView = {
        return Bundle.main.loadNibNamed("ValetModalFirstView", owner: nil, options: nil)?.first as? ValetModalFirstView ?? ValetModalFirstView()
    }()
    
    private let panelTransition = PanelTransition()
    private let parkingTicket: ParkingTicket
    
    init(parkingTicket: ParkingTicket) {
        self.parkingTicket = parkingTicket
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = valetModalViewFirst
        valetModalViewFirst.commonInit(delegate: self)
    }
}

extension ValetModalFirstController: ValetModalFirstViewDelegate {
    func orderParkingNow() {
        dismiss {
            let controller = ValetTimerAssembly(
                parkingTicket: self.parkingTicket,
                state: .creating(60 * 9)
            ).make()
            PushRouter(source: nil, destination: controller).route()
        }
    }
    
    func differentTime() {
        let controller = ValetModalTimeAssembly(parkingTicket: parkingTicket).make()
        panelTransition.currentPresentation = .valetTime
        controller.transitioningDelegate = panelTransition
        ModalRouter(source: self, destination: controller, modalPresentationStyle: .custom).route()
    }
}
