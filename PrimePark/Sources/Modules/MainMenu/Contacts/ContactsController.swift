import Contacts

protocol ContactsControllerDelegate: class {
    func didChooseContact(_ contact: CNContact)
}

//swiftlint:disable trailing_whitespace
final class ContactsController: UIViewController {
    private lazy var contactsView: ContactsView = {
            let view = Bundle.main.loadNibNamed("ContactsView", owner: nil, options: nil)?.first as? ContactsView ?? ContactsView()
            return view
        }()

    private var contacts: [CNContact] = [] {
        didSet {
            DispatchQueue.main.async {
                self.contactsView.setContactsArray(self.contacts)
                self.contactsView.setFormatedContacts(contactTableFormat(.russian, self.contacts))
            }
        }
    }
    private weak var delegate: ContactsControllerDelegate?

    init(delegate: ContactsControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = contactsView
        contactsView.addDelegate(self)
        contactsView.commonInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queue = DispatchQueue(label: "com.primepark", qos: .default, attributes: .concurrent, autoreleaseFrequency: .never, target: nil)
        queue.async { [weak self] in
            self?.loadContacts { data in
                self?.contacts.append(contentsOf: data)
            }
        }
    }

    private func loadContacts(doneLoadingCompletion: @escaping (_ contacts: [CNContact]) -> Void) {
        let contactStore = CNContactStore()
//        contactStore.requestAccess(for: .contacts) { (granted, error) in
//            if let error = error {
//                print("Failed to request access:", error)
//                return
//            }
//
//            if granted {
//                let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor]
//                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
//                do {
//                    var contacts: [CNContact] = []
//                    try contactStore.enumerateContacts(with: request) { (contact, _) in
//                        contacts.append(contact)
//                    }
//                    doneLoadingCompletion(contacts)
//                } catch let err {
//                    print(err)
//                }
//            }
//        }
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keys as! [CNKeyDescriptor])
                doneLoadingCompletion(containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
    }
}

extension ContactsController: ContactsViewProtocol {
    func didChooseContact(_ contact: CNContact) {
        self.delegate?.didChooseContact(contact)
        dismiss(animated: true, completion: nil)
    }
}
