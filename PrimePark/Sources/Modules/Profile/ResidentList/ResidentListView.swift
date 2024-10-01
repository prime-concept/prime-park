protocol ResidentListViewProtocol: class {
    func back()
    func info()
    func addResident()
}
//swiftlint:disable all
final class ResidentListView: UIView, TableSkeletonLoading {
    @IBOutlet weak var tableView: UITableView!

    private let headerTitles = [
        localizedWith("resident.role.inhabitant"),
        localizedWith("resident.role.cohabitant"),
        localizedWith("resident.role.guest"),
        localizedWith("resident.role.brigadier")
    ]
    private weak var residentListDelegate: ResidentListViewProtocol?
    private var ownerList: [Resident] = []
    private var residentList: [Resident] = []
    private var brigadierList: [Resident] = []
    private var guestList: [Resident] = []
    var isLoaded = false {
        didSet {
            triggerSkeletonLoading()
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)
    }

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Public API

    func commonInit() {
        tableView.register(UINib.init(nibName: "ResidentTableViewCell", bundle: nil), forCellReuseIdentifier: ResidentTableViewCell.reuseIdentifier)
        tableView.register(CustomListHeader.self, forHeaderFooterViewReuseIdentifier: CustomListHeader.defaultReuseIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        var insets = tableView.contentInset
        insets.bottom += 46
        tableView.contentInset = insets
        isLoaded = false
    }

    func addDelegate(_ delegate: ResidentListViewProtocol) {
        self.residentListDelegate = delegate
    }

    func addResidents(_ array: [Resident]) {
        self.ownerList = array.filter { $0.getRole == .resident }
        self.residentList = array.filter { $0.getRole == .cohabitant }
        self.brigadierList = array.filter { $0.getRole == .brigadier }
        self.guestList = array.filter { $0.getRole == .guest }
        isLoaded = true
    }

    // MARK: - Actions

    @IBAction private func back(_ sender: Any) {
        residentListDelegate?.back()
    }

    @IBAction private func info(_ sender: Any) {
        residentListDelegate?.info()
    }

    @IBAction private func addResident(_ sender: Any) {
        self.residentListDelegate?.addResident()
    }
}

extension ResidentListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isLoaded ? (headerTitles.count) : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isLoaded else { return 10 }
        switch section {
        case 0:
            return ownerList.count
        case 1:
            return residentList.count
        case 2:
            return guestList.count
        case 3:
            return brigadierList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomListHeader.defaultReuseIdentifier) as! CustomListHeader
        view.title.text = headerTitles[section]
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? CustomListHeader {
            if section == 0 {
                header.title.linesCornerRadius = 5
                guard isLoaded else {
                    header.title.showAnimatedGradientSkeleton()
                    return
                }
                header.title.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 50
        default:
            return 30
        }
    }

    /*
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white
            header.textLabel?.font = UIFont.primeParkFont(ofSize: 20, weight: .medium)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Localization.localize(headerTitles[section])
    }
*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResidentTableViewCell.reuseIdentifier, for: indexPath) as! ResidentTableViewCell
        
        guard isLoaded else {
            cell.contentViewCell.showAnimatedGradientSkeleton(
                usingGradient: .init(baseColor: UIColor(hex: 0x353535),
                                secondaryColor: UIColor(hex: 0x212121)),
                animation: nil,
                transition: .crossDissolve(0.25)
            )
            return cell
        }
        cell.contentViewCell.hideSkeleton()
        switch indexPath.section {
        case 0:
            cell.setData(resident: ownerList[indexPath.row])
        case 1:
            cell.setData(resident: residentList[indexPath.row])
        case 2:
            cell.setData(resident: guestList[indexPath.row])
        case 3:
            cell.setData(resident: brigadierList[indexPath.row])
        default:
            break
        }
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = Palette.blackColor
        return cell
    }
}

extension ResidentListView: UITableViewDelegate {
}
