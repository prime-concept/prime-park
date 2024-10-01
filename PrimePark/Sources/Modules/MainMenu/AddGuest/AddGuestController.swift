import Contacts

protocol AddGuestControllerDelegate: class {
    func guestAdded(_ guest: Guest)
}

final class AddGuestController: UIViewController {
    private lazy var addGuestView: AddGuestView = {
        let view = Bundle.main.loadNibNamed("AddGuestView", owner: nil, options: nil)?.first as? AddGuestView ?? AddGuestView()
        return view
    }()

    private weak var delegate: AddGuestControllerDelegate?
    private let recentGuests: [Guest]

    init(delegate: AddGuestControllerDelegate, recentGuests: [Guest]) {
        self.delegate = delegate
        self.recentGuests = recentGuests
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = addGuestView
        addGuestView.addDelegate(self)
        addGuestView.addRecentGuests(recentGuests)
        addGuestView.commonInit()
    }
}

extension AddGuestController: AddGuestViewProtocol {
    func addGuest(name: String, surname: String, patronymic: String?, phone: String) {
        let guest = Guest(name: name, surname: surname, patronymic: patronymic, phone: phone)
        self.delegate?.guestAdded(guest)
        dismiss(animated: true, completion: nil)
    }

    func showError() {
        let assembly = InfoAssembly(
            title: Localization.localize("createPass.addGuest.notFillFields.error.title"),
            subtitle: Localization.localize("createPass.addGuest.notFillFields.error.subtitle"),
            delegate: nil,
            status: .failure
        )
        let router = ModalRouter(source: self, destination: assembly.make())
        router.route()
    }

    func openContastBook() {
        let controller = ContactsController(delegate: self)
        present(module: controller)
    }

    func back() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddGuestController: ContactsControllerDelegate {
    func didChooseContact(_ contact: CNContact) {
        self.addGuestView.setData(
                                  name: contact.givenName,
                                  surname: contact.familyName,
                                  patronymic: contact.middleName,
                                  phone: contact.phoneNumber.addPassMask())
    }
}
