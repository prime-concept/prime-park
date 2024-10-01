import UIKit
import FSCalendar

// swiftlint:disable trailing_whitespace

protocol CleaningControllerProtocol: class, ModalRouterSourceProtocol {
    func setChoosenDate(date: String)
    func setChoosenTime(fromTime: String?, beforeTime: String?)
    func setChoosenType(type: Int)
    func setMinimumDate(time: String, isStart: Bool)
}

final class CleaningViewController: UIViewController {
    private lazy var сleaningView: CleaningView = {
        let view = Bundle.main.loadNibNamed("CleaningView", owner: nil, options: nil)?.first as? CleaningView ?? CleaningView(delegate: self)
        return view
    }()
    
    private lazy var parametersController: ParametersController = setupParameters()

    private let presenter: CleaningPresenterProtocol
    private var infoView: InfoView?
    private var isStartTimePicker: Bool = true
    
    let panelTransition = PanelTransition()

    init(presenter: CleaningPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.сleaningView
        self.сleaningView.setDelegate(delegate: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        self.сleaningView.setChoosenDate(date: dateFormatter.string(from: Date()))
        сleaningView.commonInit()
    }
}

extension CleaningViewController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension CleaningViewController: CleaningControllerProtocol {
    func setNowDate(isNow: Bool) {
        self.presenter.isNowDate(isNow: isNow)
    }

    func setChoosenTime(fromTime: String?, beforeTime: String?) {
        if let fromTime = fromTime {
            self.сleaningView.setStartTime(time: fromTime)
        }
        if let beforeTime = beforeTime {
            self.сleaningView.setEndTime(time: beforeTime)
        }
    }

    func setChoosenDate(date: String) {
        self.сleaningView.setChoosenDate(date: date)
    }

    func setChoosenType(type: Int) {
        self.сleaningView.setChoosenCleaningType(choosenType: type)
    }
    
    func setMinimumDate(time: String, isStart: Bool) {
        self.сleaningView.setMinimumDate(time: time, isStart: isStart)
    }
}

extension CleaningViewController: CleaningViewDelegate {
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
                ParametersData(name: localizedWith("cleaning.serviceType.springСleaning"), isSelected: true),
                ParametersData(name: localizedWith("cleaning.serviceType.cleaningAfterRenovation"), isSelected: false),
                ParametersData(name: localizedWith("cleaning.serviceType.maintenanceCleaning"), isSelected: false),
                ParametersData(name: localizedWith("cleaning.serviceType.windowCleaning"), isSelected: false),
                ParametersData(name: localizedWith("cleaning.serviceType.cleaningOther"), isSelected: false)
            ]
        ).makeAsInheritor
        
        parametersController.choosenClosure = { [weak self] (content, row) in
            self?.сleaningView.setChoosenCleaningType(choosenType: row)
            self?.presenter.setChoosenType(type: content.name)
        }
        
        panelTransition.currentPresentation = .dynamic(height: parametersController.dynamicSize)
        
        parametersController.transitioningDelegate = panelTransition
        
        return parametersController
    }
    
    func presentParameters() {
        ModalRouter(source: self, destination: parametersController, modalPresentationStyle: .custom).route()
    }

    func сleaningDidChoose(in date: Date) {
    }

    func closeController() {
        self.dismiss(animated: true, completion: nil)
    }

    func order(text: String?) {
        self.presenter.callCleaning(descriptionText: text)
    }
}
