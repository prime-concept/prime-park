//
//  DepositController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 07.06.2021.
//
// swiftlint:disable trailing_whitespace

protocol DepositControllerProtocol: AnyObject {
    func pushWeb(link: String)
    func checkDeposit()
    func showAlert(status: String)
    
    var orderId: String? { get set }
    
    func startLoadingAnimation()
    func endLoadingAnimation()
}

final class DepositController: PannableViewController, DepositControllerProtocol {
    private lazy var depositView: DepositView = {
        return Bundle.main.loadNibNamed("DepositView", owner: nil, options: nil)?.first as? DepositView ?? DepositView()
    }()
    
    var presenter: DepositPresenterProtocol?
    var orderId: String?
    
    var lastSum: String? {
        didSet {
            depositView.textField.text = lastSum
        }
    }
    
    override func loadView() {
        view = depositView
        depositView.commonInit(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        depositView.setRoom(room: LocalAuthService.shared.apartment?.strFormat() ?? "unknown room")
        subscribeOnTextFieldEvents()
    }
}

extension DepositController: DepositViewDelegate {
    
    // MARK: - View Delegate
    
    func deposit(sum: String?) {
        lastSum = sum
        presenter?.makeDepositFor(sum: sum)
    }
    
    // MARK: - Controller Protocol
    
    func pushWeb(link: String) {
        let web = WebDepositController(stringUrl: link)
        web.depositController = self
        dismiss {
            PushRouter(source: nil, destination: web).route()
        }
    }
    
    func checkDeposit() {
        guard let id = orderId else { return }
        presenter?.checkDeposit(orderId: id)
    }
    
    func showAlert(status: String) {
        print(status)
        if status == "SUCCESS" {
            AlertService.presentAlert(
                title: "Ваш счет успешно пополнен",
                subtitle: "Баланс обновится в течении 3-х рабочих дней",
                delegate: self,
                type: .info("Ок")
            )
        } else if status == "ERROR" {
            AlertService.presentAlert(
                title: "Ошибка пополнения счета",
                subtitle: "Во время пополнения счета произошла ошибка, попробуйте повторить оплату",
                delegate: self,
                type: .info("Ок")
            )
        } else {
            AlertService.presentAlert(
                title: localizedWith("charges.refill.allert"),
                subtitle: "",
                delegate: self,
                type: .info("Ок")
            )
        }
    }
    
    func startLoadingAnimation() {
        depositView.startLoading()
    }
    
    func endLoadingAnimation() {
        depositView.stopLoading()
    }
    
    // MARK: -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func subscribeOnTextFieldEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    func keyboardDidShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            additionalCardHeightConstraint = keyboardHeight

            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = UIScreen.main.bounds.height * 0.6 - keyboardHeight
            }
        }
    }
    
    @objc
    func keyboardDidHide(notification: Notification) {
        additionalCardHeightConstraint = 0
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = UIScreen.main.bounds.height * 0.6
        }
    }
}

extension DepositController: PrimeAlertControllerDelegate {
    func buttonTapped(_ tag: Int, alert: PrimeAlertController) {
        alert.dismiss {
            tag == 1 ? self.presenter?.makeDepositFor(sum: self.lastSum) : ()
        }
    }
}
