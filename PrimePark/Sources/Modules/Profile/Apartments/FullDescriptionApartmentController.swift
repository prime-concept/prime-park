//
//  ApartmentsController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 22.01.2021.
//

import UIKit

protocol FullDescriptionApartmentControllerProtocol: class, ModalRouterSourceProtocol {
    var viewProtocol: ApplyingLabelProtocol { get }
}
//swiftlint:disable all
class FullDescriptionApartmentViewController: UIViewController {
    private lazy var apartmentsView: FullDescriptionApartmentView = {
        return Bundle.main.loadNibNamed("FullDescriptionApartmentView", owner: nil, options: nil)?.first as? FullDescriptionApartmentView ?? FullDescriptionApartmentView()
    }()
    private var apartmentList: ApartmentList?
    var presenter: FullDescriptionApartmentPresenterProtocol
    var user: User?
    var currentRoom: Room?
    
    override func loadView() {
        self.view = apartmentsView
        self.apartmentsView.setDelegate(self)
        self.apartmentList = ApartmentList(view: apartmentsView)
        
        guard let room = currentRoom else { return }
        self.viewProtocol.applyRoomFormat(format: room.strFormat(), currentRoom: room)
    }
    
    init(presenter: FullDescriptionApartmentPresenterProtocol, user: User?, currentRoom: Room?) {
        self.presenter = presenter
        self.currentRoom = currentRoom
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FullDescriptionApartmentViewController: FullDescriptionApartmentControllerProtocol {
    var viewProtocol: ApplyingLabelProtocol {
        return apartmentsView
    }
}

extension FullDescriptionApartmentViewController: ApartmentsViewDelegate {
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    func changeApartment() {
        ModalRouter(
            source: self,
            destination: apartmentList?.make() ?? UIViewController(),
            modalPresentationStyle: .custom
        ).route()
    }
}
