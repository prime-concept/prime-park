import UIKit
import FSCalendar

// swiftlint:disable trailing_whitespace

protocol DryCleaningViewProtocol: class, ModalRouterSourceProtocol {
    func setChoosenDate(date: String)
    func setChoosenTime(fromTime: String?, beforeTime: String?)
    func setChoosenType(type: Int)
    func setMinimumDate(time: String, isStart: Bool)
}

final class DryCleaningViewController: UIViewController {
    private lazy var dryCleaningView: DryCleaningView = {
        let view = Bundle.main.loadNibNamed("DryCleaningView", owner: nil, options: nil)?.first as? DryCleaningView ?? DryCleaningView(delegate: self)
        return view
    }()
    
    private lazy var parametersController: ParametersController = setupParameters()

    private let presenter: DryCleaningPresenterProtocol
    private var infoView: InfoView?
    private var isStartTimePicker: Bool = true
    
    let panelTransition = PanelTransition()

    init(presenter: DryCleaningPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.dryCleaningView
        self.dryCleaningView.setDelegate(delegate: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        self.dryCleaningView.setChoosenDate(date: dateFormatter.string(from: Date()))
        dryCleaningView.commonInit()
    }
}

extension DryCleaningViewController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension DryCleaningViewController: DryCleaningViewProtocol {
    func setNowDate(isNow: Bool) {
        self.presenter.isNowDate(isNow: isNow)
    }

    func setChoosenTime(fromTime: String?, beforeTime: String?) {
        if let fromTime = fromTime {
            self.dryCleaningView.setStartTime(time: fromTime)
        }
        if let beforeTime = beforeTime {
            self.dryCleaningView.setEndTime(time: beforeTime)
        }
    }

    func setChoosenDate(date: String) {
        self.dryCleaningView.setChoosenDate(date: date)
    }

    func setChoosenType(type: Int) {
        self.dryCleaningView.setChoosenDryCleaningType(choosenType: type)
    }
    
    func setMinimumDate(time: String, isStart: Bool) {
        self.dryCleaningView.setMinimumDate(time: time, isStart: isStart)
    }
}

extension DryCleaningViewController: DryCleaningViewDelegate {
    func setTime(time: Date, isStart: Bool) {
        self.presenter.validateTime(time: time, isStart: isStart)
    }
    
    func chooseTime(isStart: Bool) {
        self.isStartTimePicker = isStart
        self.presenter.openTimePicker(forStart: isStart)
    }

    func openCalendar() {
        self.presenter.openCalendar()
    }
    
    func setupParameters() -> ParametersController {
        parametersController = ParametersAssembly(
            content: [
                ParametersData(name: localizedWith("dryCleaning.serviceType.dryCleaningClothes"), isSelected: true),
                ParametersData(name: localizedWith("dryCleaning.serviceType.dryCleaningFurniture"), isSelected: false),
                ParametersData(name: localizedWith("dryCleaning.serviceType.dryCleaningCarpet"), isSelected: false),
                ParametersData(name: localizedWith("dryCleaning.serviceType.dryCleaningCurtain"), isSelected: false),
                ParametersData(name: localizedWith("dryCleaning.serviceType.dryCleaningOther"), isSelected: false)
            ]
        ).makeAsInheritor
        
        parametersController.choosenClosure = { [weak self](content, row) in
            self?.dryCleaningView.setChoosenDryCleaningType(choosenType: row)
            self?.presenter.setChoosenType(type: content.name)
        }
        
        panelTransition.currentPresentation = .dynamic(height: parametersController.dynamicSize)
        
        parametersController.transitioningDelegate = panelTransition
        
        return parametersController
    }
    
    func presentParameters() {
        ModalRouter(source: self, destination: parametersController, modalPresentationStyle: .custom).route()
    }

    func dryCleaningDidChoose(in date: Date) {
    }

    func closeController() {
        self.dismiss(animated: true, completion: nil)
    }

    func order(text: String?) {
        self.presenter.callDryCleaning(descriptionText: text)
    }
}
