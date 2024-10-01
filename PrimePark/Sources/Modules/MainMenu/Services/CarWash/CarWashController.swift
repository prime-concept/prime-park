import UIKit
import FSCalendar

// swiftlint:disable trailing_whitespace

protocol CarWashViewProtocol: AnyObject, ModalRouterSourceProtocol, PushRouterSourceProtocol {
    func updateHistoryRecords(records: [HistoryRecordViewModel])
    func setDefaultServiceType(type: String)
}

final class CarWashViewController: UIViewController {
    private lazy var carWashView: CarWashView = {
        let view = Bundle.main.loadNibNamed("CarWashView", owner: nil, options: nil)?.first as? CarWashView ?? CarWashView(delegate: self)
        return view
    }()
    

    private let presenter: CarWashPresenterProtocol
    private var infoView: InfoView?
    private var isStartTimePicker: Bool = true
    private lazy var keyTransferController: ParametersController = setupKeyTransfer()

    let panelTransition = PanelTransition()
    
    init(presenter: CarWashPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.carWashView
        self.carWashView.setDelegate(delegate: self)
        carWashView.commonInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.presenter.uploadCarWashServices()
        self.presenter.getCarWashHistory()
    }
}

extension CarWashViewController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension CarWashViewController: CarWashViewProtocol {
    func updateHistoryRecords(records: [HistoryRecordViewModel]) {
        self.carWashView.setRecordsHistory(history: records)
    }

    func setDefaultServiceType(type: String) {
        self.carWashView.setServiceType(type: type)
    }

    func openCalendar() {
        let timeSlot = self.presenter.getSelectedDateAndTime()
        let assembly = CarWashCalendarAssembly(
            selectedDate: timeSlot.0,
            selectedTime: timeSlot.1) { timeslot, dayIndex, timeIndex in
                self.presenter.updateSelectedTimeslot(
                    timeslot: timeslot,
                    dayIndex: dayIndex,
                    timeIndex: timeIndex
                )
                self.carWashView.setDateLabel(date: timeslot.getDate().string("dd.MM.yyyy, HH:mm"))
            }
        let calendarController = assembly.make()
        panelTransition.currentPresentation = .dynamic(height: 360)
        calendarController.transitioningDelegate = panelTransition
        
        ModalRouter(
            source: self,
            destination: calendarController,
            modalPresentationStyle: .custom
        ).route()
        
        return
    }
}

extension CarWashViewController: CarWashViewDelegate {
    func openHistoryRecord(index: Int) {
        self.presenter.openRecordDetail(index: index)
    }
    
    func presentKeyTransferTypes() {
        ModalRouter(source: self, destination: keyTransferController, modalPresentationStyle: .custom).route()
    }
    
    func setupKeyTransfer() -> ParametersController {
        keyTransferController = ParametersAssembly(
            content: [
                ParametersData(name: localizedWith("carWash.driver.comePersonally"), isSelected: true),
                ParametersData(name: localizedWith("carWash.driver.valetService"), isSelected: false)
            ]
        ).makeAsInheritor
        
        keyTransferController.choosenClosure = { [weak self] (content, row) in
            self?.carWashView.setChoosenKeyTransferType(type: content.name)
            self?.presenter.setComment(comment: content.name)
        }
        
        panelTransition.currentPresentation = .dynamic(height: keyTransferController.dynamicSize)
        
        keyTransferController.transitioningDelegate = panelTransition
        
        return keyTransferController
    }

    func presentServices() {
        let controller =
        CarWashServiceViewController(services: self.presenter.getCarWashServices()) { service, index in
            self.carWashView.setServiceType(type: service.title)
            self.presenter.updateSelectedService(index: index)
        }
        panelTransition.currentPresentation = .dynamic(height: UIScreen.main.bounds.height * 0.45)
        controller.transitioningDelegate = panelTransition
        
        ModalRouter(
            source: self,
            destination: controller,
            modalPresentationStyle: .custom
        ).route()
        
        return
    }
    
    func closeController() {
        self.navigationController?.popViewController(animated: true)
    }

    func makeOrder() {
        self.presenter.createCarWashRequest()
    }
    
    func openMoreInfo() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let offer = UIAlertAction(title: localizedWith("carWash.offer"), style: .default, handler: self.presentPrivacyPolicyViewController)
        offer.setValue(UIImage(named: "offer_image")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        offer.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        offer.setValue(UIColor.white.withAlphaComponent(0.8), forKey: "titleTextColor")
        
        let tariff = UIAlertAction(title: localizedWith("carWash.tariff"), style: .default, handler: self.presentTariffViewController)
        tariff.setValue(UIImage(named: "tariff_image")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        tariff.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        tariff.setValue(UIColor.white.withAlphaComponent(0.8), forKey: "titleTextColor")
        
        actionSheet.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor(hex: 0x333333)
        actionSheet.addAction(offer)
        actionSheet.addAction(tariff)
        
        let cancel = UIAlertAction(title: localizedWith("alert.button.cancel"), style: .cancel, handler: nil)
        cancel.setValue(Palette.mainColor, forKey: "titleTextColor")
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }

    private func presentPrivacyPolicyViewController(action: UIAlertAction) {
        ModalRouter(
            source: self,
            destination: WebViewController(stringURL: "https://primeparking.ru/ofertamoyka"),
            modalPresentationStyle: .popover
        ).route()
    }
    
    private func presentTariffViewController(action: UIAlertAction) {
        ModalRouter(
            source: self,
            destination: WebViewController(stringURL: "https://primeparking.ru/uslugi"),
            modalPresentationStyle: .popover
        ).route()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
            // Fallback on earlier versions
        }
    }
}
