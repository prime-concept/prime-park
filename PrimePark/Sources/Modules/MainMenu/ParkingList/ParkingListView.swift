import WebKit

//swiftlint:disable all
protocol ParkingListViewDelegate: AnyObject {
    func back()
    func newIssue()
    func showDetail(for parking: ParkingTicket)
    func showInfo()

	func repeatParking(_ parking: Parking)
    
    //permanent section
    
    func chooseServiceType()
    func setCarsAmount(amount: String)
    func setMonthAmount(amount: String)
    func createPermanent()
    
    //valet section
    
    func toValetOrderScreen(type: ParkingTicket.CardType)
    func warningAlert()
}

protocol ParkingListViewProtocol {
    func changeSegmentControlIndex(_ index: Int)
    func reloadData(with cards: [ParkingTicket])
}

final class ParkingListView: UIView, ParkingListViewProtocol {

    @IBOutlet private weak var segmentedControl: PrimeSegmentControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createIssueButton: LocalizableButton!
    @IBOutlet private weak var noDataView: UIView!
    @IBOutlet private weak var inDevelopmentView: UIView!
    
    //permanent section
    @IBOutlet private weak var permanentSection: UIView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var showTextImageView: UIImageView!
    
    @IBOutlet private var carsAmountButtonArr: [LocalizableButton]!
    @IBOutlet private var monthAmountButtonArr: [LocalizableButton]!
    @IBOutlet private weak var serviceNameLabel: LocalizableLabel!
    
    @IBOutlet private weak var textViewHeightConstraint: NSLayoutConstraint!
    
    private let compressedTextViewHeight: CGFloat = 81.0
    private lazy var textViewHeight: CGFloat = {
        let newSize = textView.sizeThatFits(CGSize(width: self.frame.size.width - 30, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }()
    
    private lazy var gradient: CAGradientLayer = {
        let tempGradient = CAGradientLayer()
        tempGradient.frame = textView.bounds
        tempGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        tempGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        tempGradient.endPoint = CGPoint(x: 0.0, y: 0.9)
        return tempGradient
    }()
    
    private var textIsFull = false
    
    private var arrOfCarsModel = ["1 машина", "2 машины", "3 машины и более"]
    private var arrOfMonthModel = ["1 месяц", "3 месяца", "6 месяцев и более"]
    
    private weak var parkingDelegate: ParkingListViewDelegate?
    
    private var oneTimeParkingArray: [Parking] = Array(repeating: Parking(), count: 10) {
        didSet {
            tableView.reloadData()
            tableView.stopSolidAnimation(isLodable: false)
        }
    }
    private var permanentParkingArray: [Parking] = Array(repeating: Parking(), count: 10)
    
    // valet section
    
    @IBOutlet weak var valetTableView: UITableView!
    
    private var valetCards: [ParkingTicket] = Array(repeating: ParkingTicket(cardType: .ticket), count: 10) {
        didSet {
            valetTableView.reloadData()
            valetTableView.stopSolidAnimation(isLodable: false)
        }
    }

    // MARK: - Public API

    func commonInit() {
        tableView.registerNib(cellClass: ParkingCell.self)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        var insets = tableView.contentInset
        insets.bottom += 60
        tableView.contentInset = insets
        
        tableView.rowHeight = 73
        tableView.estimatedRowHeight = 73
        tableView.isLoadable = true
        
        changeAccess(LocalAuthService.shared.apartment?.getRole ?? .resident)
        
        //changeSegmentControlIndex(0)
        
        //permanent section
        textView.text = localizedWith("parking.about.textview")
        textView.layer.mask = gradient
        parkingDelegate?.setMonthAmount(amount: arrOfMonthModel[0])
        parkingDelegate?.setCarsAmount(amount: arrOfCarsModel[0])
        
        //valet section
        
        valetTableView.registerNib(cellClass: ValetCell.self)
        valetTableView.registerNib(headerClass: ValetHeaderFooter.self)
        valetTableView.dataSource = self
        valetTableView.delegate = self
        valetTableView.isLoadable = true
        
        var valetInsets = valetTableView.contentInset
        valetInsets.top += 15
        valetTableView.contentInset = valetInsets
        
        segmentedControl.delegate = self
    }
    
    func reloadData(with cards: [ParkingTicket]) {
        self.valetCards = cards
    }

    func addDelegate(_ delegate: ParkingListViewDelegate) {
        self.parkingDelegate = delegate
    }

    func addOnetimeParkingArray(_ array: [Parking]) {
        self.oneTimeParkingArray = array
        noDataView.isHidden = !oneTimeParkingArray.isEmpty
    }

    func addPermanentParkingArray(_ array: [Parking]) {
        self.permanentParkingArray = array
    }

    func addValetCards(_ array: [ParkingTicket]) {
        valetCards = array
    }
    

    func setButtonEnabled(_ enabled: Bool) {
        self.createIssueButton.isEnabled = enabled
    }
    
    func changeSegmentControlIndex(_ index: Int) {
        segmentedControl.selectedSegmentIndex = index
        segmentDidChange(index: index)
    }
    
    func changeAccess(_ role: Role) {
        segmentedControl.isHidden = role == .brigadier ? true : false
    }

    // MARK: - Actions

    @IBAction private func back(_ sender: Any) {
        parkingDelegate?.back()
    }

    @IBAction private func showInfo(_ sender: Any) {
        parkingDelegate?.showInfo()
    }
    
    func segmentDidChange(index: Int) {
        switch index {
        case 0:
            noDataView.isHidden = true/*!oneTimeParkingArray.isEmpty*/
            inDevelopmentView.isHidden = true
            permanentSection.isHidden = true
            valetTableView.isHidden = true
            createIssueButton.isHidden = false
            createIssueButton.localizedKey = "passList.newParkingButton.title"
            tableView.isHidden = false
            tableView.reloadData()
        case 1:
            inDevelopmentView.isHidden = true
            valetTableView.isHidden = true
            permanentSection.isHidden = false
            createIssueButton.isHidden = false
            tableView.isHidden = true
            createIssueButton.localizedKey = "createParking.parkingOrderButton.title"
        case 2:
            inDevelopmentView.isHidden = true
            createIssueButton.isHidden = true
            permanentSection.isHidden = true
            tableView.isHidden = true
            valetTableView.isHidden = false
            valetTableView.reloadData()
        default:
            return
        }
    }

    @IBAction private func createNewIssue(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            print(localizedWith("createParking.permanent.createOrder.success.subtitle"))
            self.parkingDelegate?.newIssue()
        } else {
            parkingDelegate?.createPermanent()
        }
    }
    
    func permanentDone() {
        createIssueButton.endButtonLoadingAnimation(defaultTitle: localizedWith("createParking.parkingOrderButton.title"))
    }
    
    //MARK: - Permanent section
    
    func setServiceType(name: String) {
        serviceNameLabel.text = name
    }
    
    @IBAction func chooseMonthAmount(_ sender: LocalizableButton) {
        for one in monthAmountButtonArr {
            one.backgroundColor = Palette.darkColor
        }
        sender.backgroundColor = Palette.goldColor
        parkingDelegate?.setMonthAmount(amount: arrOfMonthModel[sender.tag])
    }
    
    
    @IBAction func chooseCarsAmount(_ sender: LocalizableButton) {
        for one in carsAmountButtonArr {
            one.backgroundColor = Palette.darkColor
        }
        sender.backgroundColor = Palette.goldColor
        parkingDelegate?.setCarsAmount(amount: arrOfCarsModel[sender.tag])
    }
    
    @IBAction func chooseServiceType(_ sender: UITapGestureRecognizer) {
        self.parkingDelegate?.chooseServiceType()
    }
    
    @IBAction func openDesriptionText(_ sender: UITapGestureRecognizer) {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.15) {
            if self.textIsFull {
                self.textViewHeightConstraint.constant = self.compressedTextViewHeight
                self.textView.layer.mask = self.gradient
                self.showTextImageView.isHighlighted = false
            } else {
                self.textViewHeightConstraint.constant = self.textViewHeight
                self.gradient.removeFromSuperlayer()
                self.showTextImageView.isHighlighted = true
            }
            self.layoutIfNeeded()
        }
        textIsFull.toggle()
    }
}

extension ParkingListView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView === tableView ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.tableView {
            return oneTimeParkingArray.count
        } else {
            let count = section == 0 ? getValetCards(type: .ticket).count : getValetCards(type: .subscription).count
            return count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.tableView === tableView {
            let cell: ParkingCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setData(parking: oneTimeParkingArray[indexPath.row])
            return cell
        } else {
            let cell: ValetCell = tableView.dequeueReusableCell(for: indexPath)
            
            let valetCards = indexPath.section == 0 ? getValetCards(type: .ticket) : getValetCards(type: .subscription)
            
            cell.data = valetCards[indexPath.row]
            return cell
        }
    }
    
    //MARK: - Table View Headers
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableView === valetTableView {
            if let header = view as? ValetHeaderFooter {
                header.changeStyle(to: section == 0 ? .ticket : .subscription)
                header.delegate = self
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView === valetTableView {
            let header: ValetHeaderFooter = tableView.dequeueReusableHeaderFooterView()
            return header
        }
        return nil
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView === valetTableView {
            return 74
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.startSolidAnimation()
    }
    
}

extension ParkingListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === valetTableView {
            let content = indexPath.section == 0 ? getValetCards(type: .ticket) : getValetCards(type: .subscription)
            parkingDelegate?.showDetail(for: content[indexPath.row])
			return
        }

		if tableView === self.tableView {
			let parking = self.oneTimeParkingArray[indexPath.row]
			self.parkingDelegate?.repeatParking(parking)
			return
		}
    }
}

extension ParkingListView: ValetOrderProtocol {
    
    func order(type: ParkingTicket.CardType) {
        parkingDelegate?.toValetOrderScreen(type: type)
    }
}

extension ParkingListView: PrimeSegmentControlDelegate {
    func didChange(index: Int) {
        segmentDidChange(index: index)
    }
}

extension ParkingListView {
    private func getValetCards(type: ParkingTicket.CardType) -> [ParkingTicket] {
        switch type {
        case .ticket:
            return valetCards.filter { $0.cardType == .ticket }
        case .subscription:
            return valetCards.filter { $0.cardType == .subscription }
        case .all:
            return valetCards
        }
    }
}
