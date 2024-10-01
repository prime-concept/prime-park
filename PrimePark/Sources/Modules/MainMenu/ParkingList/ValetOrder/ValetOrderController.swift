    //
//  ValetOrderController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 03.05.2021.
//
//swiftlint:disable trailing_whitespace
import UIKit

protocol ValetOrderControllerProtocol: AnyObject {
    func appearValetOrderInfo(with details: VehicleDetails?)
	var vehicleDetails: VehicleDetails? { get set }
    
    func forwardToTimerScreen(with fullTime: Int)
}

class ValetOrderController: UIViewController, ValetOrderControllerProtocol {
    private lazy var valetOrderView: ValetOrderView = {
        return Bundle.main.loadNibNamed("ValetOrderView", owner: self, options: nil)?.first as? ValetOrderView ?? ValetOrderView()
    }()
    private var vehicleDetailsView: UIView?
    
    private let isExistingCard: Bool
    var presenter: ValetOrderPresenter
	var vehicleDetails: VehicleDetails? {
		didSet {
			stopButtonLoadingAnimation(for: vehicleDetails)
			appearValetOrderInfo(with: vehicleDetails)
		}
	}
    
    private let panelTransition = PanelTransition()
    
    private var keyboardStatus = false
    
    init(presenter: ValetOrderPresenter, isExistingCard: Bool) {
        self.presenter = presenter
        self.isExistingCard = isExistingCard
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = valetOrderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationController?.setNavigationBarHidden(true, animated: true)
        
        valetOrderView.delegate = self
        valetOrderView.commonInit(ticket: presenter.parkingTicket)
        
        subscribeOnTextFieldEvents()
        
        guard isExistingCard else { return }
        
        presenter.getFullVehicleDetails()
        valetOrderView.searchButton.startButtonLoadingAnimation()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ValetOrderController: ValetOrderViewDelegate {
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func tapSearchButton(ticket: String?, pin: String?) {

        presenter.setFromView(ticket: ticket, pin: pin)
        
        if vehicleDetails != nil {
            panelTransition.currentPresentation = .valetFirst
            let controller = ValetModalFirstAssembly(parketTicket: presenter.parkingTicket).make()
            controller.transitioningDelegate = panelTransition
            ModalRouter(source: self, destination: controller, modalPresentationStyle: .custom).route()
            return
        }
        
        presenter.findGuestCard()
    }
    
    func tapLaterButton() {
        back()
    }
    
    func appearValetOrderInfo(with details: VehicleDetails?) {
        vehicleDetailsView?.removeFromSuperview()
		let isValid = details != nil
        isValid ? valetOrderView.activeButtonForService(isFound: true) : ()
        if let view = Bundle.main.loadNibNamed("VehicleDetailsView", owner: nil, options: nil)?[isValid ? 1 : 0] as? UIView {
			if let validView = view as? VehicleDetailsView {
				validView.data = vehicleDetails
			}
            vehicleDetailsView = view
            view.translatesAutoresizingMaskIntoConstraints = false
            valetOrderView.addSubview(view)
            view.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(valetOrderView.pinTextField.snp.bottom).inset(-50)
            }
        }
    }
	
	private func stopButtonLoadingAnimation(for details: VehicleDetails?) {
        valetOrderView.searchButton.endButtonLoadingAnimation(defaultTitle: details != nil ? "Подать машину" : "Найти")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension ValetOrderController {
    func subscribeOnTextFieldEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    func keyboardDidShow(notification: Notification) {
        guard !keyboardStatus else { return }
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let bottom = UIApplication.shared.windows[0].safeAreaInsets.bottom
            
            self.valetOrderView.searchButtonBottomConstraint.constant = keyboardHeight - bottom - 30
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        keyboardStatus = true
    }
    
    @objc
    func keyboardDidHide(notification: Notification) {
        guard keyboardStatus else { return }
        self.valetOrderView.searchButtonBottomConstraint.constant = 30
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        keyboardStatus = false
    }
    
    func forwardToTimerScreen(with fullTime: Int) {
        
        DispatchQueue.main.async {
            let timerController = ValetTimerAssembly(parkingTicket: self.presenter.parkingTicket, state: .existing(TimeInterval(fullTime))).make()
            
            PushRouter(
                source: self,
                destination: timerController
            ).route()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        [valetOrderView.pinTextField, valetOrderView.ticketTextField].forEach { $0?.resignFirstResponder() }
    }
}
