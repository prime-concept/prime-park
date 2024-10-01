import Contacts

protocol ContactsViewProtocol: AnyObject {
    func didChooseContact(_ contact: CNContact)
}

final class ContactsView: UIView {
    private weak var contactDelegate: ContactsViewProtocol?
    private var contacts: [CNContact] = []
    private var copyContacts: [CNContact] = []
    private var sectionTitles = [String]()
    
    var contactTableFormatData: [(title: String, contacts: [CNContact])] = [] {
        didSet {
            tableView.reloadData()
        }
    }
        
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Initialization

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Public API

    func commonInit() {
        tableView.register(cellClass: UITableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        self.backgroundColor = Palette.darkColor
        self.tableView.sectionIndexBackgroundColor = Palette.darkColor
        //search bar
        self.searchBar.barTintColor = Palette.darkColor
        self.searchBar.delegate = self
    }

    func addDelegate(_ delegate: ContactsViewProtocol) {
        self.contactDelegate = delegate
    }

    func setContactsArray(_ array: [CNContact]) {
        self.contacts = array
        self.copyContacts = array
    }
    
    func setFormatedContacts(_ array: [(title: String, contacts: [CNContact])]) {
        self.contactTableFormatData = array
    }
}

extension ContactsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactTableFormatData[section].contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.contentView.backgroundColor = Palette.darkColor
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = contactTableFormatData[indexPath.section].contacts[indexPath.row].toString
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactTableFormatData[section].title
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactTableFormatData.count
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return contactTableFormatData.map {
            
            guard let character = $0.title.first else {
                return "-"
            }
            
            return String(character)
        }
        //alphabet(of: .russian) + ["#"]
    }
}

extension ContactsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.contactDelegate?.didChooseContact(contactTableFormatData[indexPath.section].contacts[indexPath.row])
    }
}

extension ContactsView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            contacts = copyContacts.filter { $0.familyName.contains(searchText) ||
                                            $0.givenName.contains(searchText) }
            contactTableFormatData = contactTableFormat(.russian, contacts)
            return
        }
        contacts = copyContacts
        contactTableFormatData = contactTableFormat(.russian, contacts)
    }
}
//
