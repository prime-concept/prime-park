import UIKit

protocol AuthViewProtocol: class, PushRouterSourceProtocol {
    func unblockButton()
}

final class AuthViewController: UIViewController, AuthViewProtocol {
    private lazy var authView = self.view as? AuthView

    private lazy var countryCodePresentationManager = FloatingControllerPresentationManager(
        context: .authCountryCodes,
        sourceViewController: self
    )

    private var presenter: AuthPresenterProtocol

    init(presenter: AuthPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = AuthView(delegate: self)

        self.navigationController?.navigationBar.applyAuthStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.authView?.resetToDef()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.authView?.viewWillClose()
		self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func unblockButton() {
        self.authView?.unblockButton()
    }
}

extension AuthViewController: AuthViewDelegate {
    func onSelectCodeTap(currentCode: CountryCode) {
        let assembly = CountryCodesAssembly(countryCode: currentCode, delegate: self)
        let countryCodesController = assembly.make()

        self.countryCodePresentationManager.contentViewController = countryCodesController
        self.countryCodePresentationManager.track(scrollView: assembly.scrollView)

        self.countryCodePresentationManager.present()
    }
	
	func onNextButtonTap(phone: String) {
		self.presenter.sendPhone(with: phone)
	}

	func onResidentButtonTap(phone: String) {
		self.presenter.becomeResident()
	}
}

extension AuthViewController: CountryCodeSelectionDelegate {
    func select(countryCode: CountryCode) {
        self.authView?.select(countryCode: countryCode)
    }

    func onCallButtonTap() {
        self.presenter.call()
    }
}
