//
//  ValetTimerController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.05.2021.
//
// swiftlint:disable trailing_whitespace
import UIKit

protocol ValetTimerControllerProtocol: AnyObject, ModalRouterSourceProtocol {
    var waitTime: String { get set }
    var isForcedToRemove: Bool { get set }
    
    func errorAlert()
}

class ValetTimerController: UIViewController, ValetTimerControllerProtocol, ValetTimeHolder {
    private lazy var valetTimerView: ValetTimerView = {
        return Bundle.main.loadNibNamed("ValetTimerView", owner: self, options: nil)?.first as? ValetTimerView ?? ValetTimerView()
    }()
    
    var presenter: ValetTimerPresenterProtocol
    
    private let panelTransition = PanelTransition()
    
    var waitTime = "" {
        didSet {
            valetTimerView.timerProgressBar.timeLabel.text = "\(waitTime)"
        }
    }
    
    var isForcedToRemove: Bool = false {
        didSet {
            valetTimerView.isForcedToRemove = isForcedToRemove
        }
    }
    
    var choosenTime = Date() + .minute(9) {
        didSet {
            // stop part
            self.valetTimerView.stopProgressBar()
            self.presenter.stopTimer()
            
            // compute diff time
            let seconds = Date.formDiffDate(
                date: Date().dateWithCurrentTimeZone(),
                time: choosenTime
            )
            
            //valetTimerView.startAnimation(duration: seconds, toValue: 1)
            
            presenter.changeTime(newInterval: seconds)
        }
    }
    
    init(presenter: ValetTimerPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC Methods
    
    override func loadView() {
        view = valetTimerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        presenter.readyToFire = { [weak self] allSeconds, part in
            guard let strongSelf = self else { return }
            
            strongSelf.valetTimerView.commonInit(
                delegate: strongSelf,
                duration: allSeconds,
                fromValue: part,
                isForcedToRemove: false
            )
        }
        
        presenter.startCountDown()
    }
    
    func errorAlert() {
        AlertService.presentAlert(title: "Error", subtitle: "Error of giving car!", delegate: self, type: .info("ok"))
    }
}

extension ValetTimerController: PrimeAlertControllerDelegate {
    func buttonTapped(_ tag: Int, alert: PrimeAlertController) {
        dismiss {
            //self.pop()
            if let count = self.navigationController?.viewControllers.count,
               let controller = self.navigationController?.viewControllers[count - 1 - 2] {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
}

extension ValetTimerController: ValetTimerViewDelegate {
    func back() {
        presenter.stopTimer()
        pop()
    }
    
    func stopServe() {
        //showAlert(title: "Отмена подачи", subtitle: "Уверены, что хотите остановить подачу машины?", source: nil)
        let alert = UIAlertController(
            title: "Отмена подачи",
            message: "Уверены, что хотите остановить подачу машины?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Нет",
            style: .default,
            handler: nil))
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .cancel,
            handler: { _ in
                self.presenter.stopServe()
                self.presenter.stopTimer()
                self.valetTimerView.stopProgressBar()
                
                if let count = self.navigationController?.viewControllers.count,
                   let controller = self.navigationController?.viewControllers[count - 1 - 2] {
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
        ))
        //alert.view.layer.cornerRadius = 22
        alert.view.tintColor = .white
        present(module: alert)
    }
    
    func changeTime() {
        let controller = ValetTimePickerAssembly(presenter: self).make()
        panelTransition.currentPresentation = .valetTimePicker
        controller.transitioningDelegate = panelTransition
        ModalRouter(
            source: self,
            destination: controller,
            modalPresentationStyle: .custom
        ).route()
    }
}

extension ValetTimerController {
    func showAlert(title: String, subtitle: String?, source: ModalRouterSourceProtocol?) {
        let assembly = InfoAssembly(title: title, subtitle: subtitle, delegate: nil)
        let router = ModalRouter(source: source, destination: assembly.make())
        router.route()
    }
}
