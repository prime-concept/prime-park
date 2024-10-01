import UIKit

protocol VerificationViewProtocol: ModalRouterSourceProtocol, PushRouterSourceProtocol {
}

final class VerificationViewController: UIViewController {
    private lazy var verificationView = self.view as? VerificationView
    private let presenter: VerificationPresenterProtocol
    private var infoView: InfoView?

    init(presenter: VerificationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Change after failure
        verificationView?.resetToDef()
    }
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verificationView?.codeTextField.becomeFirstResponder()
    }

    override func loadView() {
        self.view = VerificationView(delegate: self)
    }
}

extension VerificationViewController: VerificationViewProtocol {
}

extension VerificationViewController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension VerificationViewController: VerificationViewDelegate {
    func onNextButtonTap(code: String) {
        self.presenter.verify(with: code)
    }

    func onSendButtonTap() {
        self.presenter.sendCode()
        self.verificationView?.setupView()
    }
}
