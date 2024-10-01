import Contacts

// swiftlint:disable trailing_whitespace
protocol AddResidentControllerProtocol: class, ModalRouterSourceProtocol {
    func close()
    
    // callback
    
    func loadingDone()
}

final class AddResidentController: UIViewController {
    private lazy var addResidentView: AddResidentView = {
        let view = Bundle.main.loadNibNamed("AddResidentView", owner: nil, options: nil)?.first as? AddResidentView ?? AddResidentView()
        return view
    }()

    private let presenter: AddResidentPresenterProtocol

    init(presenter: AddResidentPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = addResidentView
        addResidentView.addDelegate(self)
        addResidentView.commonInit()
    }
}

extension AddResidentController: AddResidentViewProtocol {
    func showInfo() {
    }

    func addResident(_ resident: Resident) {
        presenter.addResident(resident)
    }

    func showError() {
        presenter.showError()
    }

    func openContastBook() {
        let controller = ContactsController(delegate: self)
        present(module: controller)
    }

    func back() {
        navigationController?.popViewController(animated: true)
    }
}

extension AddResidentController: ContactsControllerDelegate {
    func didChooseContact(_ contact: CNContact) {
        self.addResidentView.setData(name: contact.givenName, surname: contact.familyName, patronymic: contact.middleName, phone: Converting.phoneNumberWithContryCode(contact: contact)[0])
    }
}

extension AddResidentController: AddResidentControllerProtocol {
    func loadingDone() {
        addResidentView.loadingDone()
    }
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
}
