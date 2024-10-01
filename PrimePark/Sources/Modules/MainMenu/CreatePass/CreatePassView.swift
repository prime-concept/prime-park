protocol CreatePassViewDeleagate: class {
    func back()
    func info()
    func chooseDate(interval: Bool)
    func chooseEntrance()
    func needAddGuest()
    func deleteGuest(at index: Int)
    func createPass(type: PassType)
    func createParking(carNumber: String, guest: Guest, isResidentPay: Bool)
    func showGuestsError()
    func showNoGuestsError()
    func showNoCarDataError()
    func showParkingAlert()
}

final class CreatePassView: UIView {
    private weak var createPassDelegate: CreatePassViewDeleagate?
    private var guests: [Guest] = []
    private var typeButtons: [UIButton] = []
    private let unselectedBackgroundColor = UIColor(hex: 0x606060).withAlphaComponent(0.4)
    private var isResidentPay = true
    private let maxGuestsAmount = 5
    private var type: PassType = .oneTime
    private let guestViewHeight: CGFloat = 67
    private let guestViewOffset: CGFloat = 5
    private var permissions: [PassType] = []

    @IBOutlet private weak var oneTimeButton: LocalizableButton!
    @IBOutlet private weak var oneDayButton: LocalizableButton!
    @IBOutlet private weak var temporaryButton: LocalizableButton!
    @IBOutlet private weak var permanentButton: LocalizableButton!
    @IBOutlet private weak var needParkingSwitch: UISwitch!
    @IBOutlet private weak var carNumberTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var residentButton: LocalizableButton!
    @IBOutlet private weak var guestButton: LocalizableButton!
    @IBOutlet private weak var dateTitleLabel: LocalizableLabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var entranceLabel: UILabel!
    @IBOutlet private weak var commentTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var dateToNeedParkingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dateToParkingDetailTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dateToTypeConstraint: NSLayoutConstraint!
    @IBOutlet private weak var entranceToDateTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var entranceToTypeTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var needParkingView: UIView!
    @IBOutlet private weak var parkingDetailView: UIView!
    @IBOutlet private weak var chooseDateView: UIView!
    @IBOutlet private weak var noGuestView: RoundedView!
    @IBOutlet private weak var guestsStackView: UIStackView!
    @IBOutlet private var guestViews: [RoundedView]!
    @IBOutlet private var nameLabels: [UILabel]!
    @IBOutlet private var phoneLabels: [UILabel]!
    @IBOutlet private weak var guestsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carNumberBottomToTopDate: NSLayoutConstraint!
    @IBOutlet weak var parkingBottomToDateTop: NSLayoutConstraint!
    @IBOutlet private weak var createPassButton: LocalizableButton!

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
        typeButtons = [oneTimeButton, oneDayButton, temporaryButton, permanentButton]
        parkingDetailView.isHidden = true
        needParkingView.isHidden = true
        dateToNeedParkingConstraint.priority = UILayoutPriority(rawValue: 997)
        dateToParkingDetailTopConstraint.priority = UILayoutPriority(rawValue: 996)
        dateToTypeConstraint.priority = UILayoutPriority(rawValue: 1000)
        var insets = scrollView.contentInset
        insets.bottom += 80
        scrollView.contentInset = insets
        for textField in [commentTextField, carNumberTextField] {
            textField?.delegate = self
        }
        self.carNumberTextField.autocapitalizationType = .allCharacters
        showGuests()
        changeAccess(LocalAuthService.shared.apartment?.getRole ?? .resident)
    }

    func addDelegate(_ delegate: CreatePassViewDeleagate) {
        self.createPassDelegate = delegate
    }

    func addGuestsArray(_ array: [Guest]) {
        self.guests = array
        showGuests()
    }

    func addGuest(_ man: Guest) {
        addViewInStack(for: man)
    }

    func setChoosenDate(date: String) {
        self.dateLabel.text = date
    }

    func setEntrance(entrance: Entrance) {
        self.entranceLabel.text = entrance.localizedName
    }
    
    func selectButton(at type: PassType) {
        self.type = type
        for button in typeButtons {
            button.backgroundColor = unselectedBackgroundColor
        }
        switch type {
        case .oneTime:
            typeButtons[0].backgroundColor = Palette.goldColor
        case.oneDay:
            typeButtons[1].backgroundColor = Palette.goldColor
        case .temporary:
            typeButtons[2].backgroundColor = Palette.goldColor
        case .permanent:
            typeButtons[3].backgroundColor = Palette.goldColor
        default:
            return
        }
        changePassType(type)
    }

    func addPermissions(_ permissions: [PassType]) {
        self.permissions = permissions
        for item in permissions {
            switch item {
            case .oneTime:
                typeButtons.append(oneTimeButton)
                oneTimeButton.isHidden = false
            case .oneDay:
                typeButtons.append(oneDayButton)
                oneDayButton.isHidden = false
            case .temporary:
                typeButtons.append(temporaryButton)
                temporaryButton.isHidden = false
            case .permanent:
                typeButtons.append(permanentButton)
                permanentButton.isHidden = false
            default:
                return
            }
        }
    }
    func changeAccess(_ role: Role) {
        switch role {
        case .resident:
            permanentButton.isHidden = false
            carNumberBottomToTopDate.priority = UILayoutPriority(999)
            parkingBottomToDateTop.priority = UILayoutPriority(1000)
        case .cohabitant:
            permanentButton.isHidden = true
            carNumberBottomToTopDate.priority = UILayoutPriority(1000)
            parkingBottomToDateTop.priority = UILayoutPriority(999)
        case .brigadier:
            permanentButton.isHidden = true
            carNumberBottomToTopDate.priority = UILayoutPriority(1000)
            parkingBottomToDateTop.priority = UILayoutPriority(999)
        default:
            permanentButton.isHidden = false
            carNumberBottomToTopDate.priority = UILayoutPriority(999)
            parkingBottomToDateTop.priority = UILayoutPriority(1000)
        }
    }

    // MARK: - Private API

	private func changePassType(_ type: PassType) {
		switch type {
		case .oneTime, .oneDay:
			needParkingView.isHidden = true
			chooseDateView.isHidden = false
			parkingDetailView.isHidden = true
			needParkingSwitch.setOn(false, animated: true)
			dateTitleLabel.text = Localization.localize("createPass.dateOfVisit.title")
//			dateToNeedParkingConstraint.priority = UILayoutPriority(rawValue: 1000)
//			dateToParkingDetailTopConstraint.priority = UILayoutPriority(rawValue: 999)
			dateToTypeConstraint.priority = UILayoutPriority(rawValue: 1000)
			entranceToDateTopConstraint.priority = UILayoutPriority(rawValue: 1000)
			entranceToTypeTopConstraint.priority = UILayoutPriority(rawValue: 999)
			guard let text = dateLabel.text else { return }
			let shortDate = String(text.prefix(10))
			dateLabel.text = shortDate
		case .permanent:
			needParkingView.isHidden = true
			parkingDetailView.isHidden = true
			chooseDateView.isHidden = true
			dateToTypeConstraint.priority = UILayoutPriority(rawValue: 1000)
			entranceToDateTopConstraint.priority = UILayoutPriority(rawValue: 999)
			entranceToTypeTopConstraint.priority = UILayoutPriority(rawValue: 1000)
		case .temporary:
			needParkingView.isHidden = true
			chooseDateView.isHidden = false
			parkingDetailView.isHidden = true
			needParkingSwitch.setOn(false, animated: true)
			dateTitleLabel.text = Localization.localize("createPass.dateIntervalOfVisit.title")
			dateToTypeConstraint.priority = UILayoutPriority(rawValue: 1000)
			entranceToDateTopConstraint.priority = UILayoutPriority(rawValue: 1000)
			entranceToTypeTopConstraint.priority = UILayoutPriority(rawValue: 999)
			dateLabel.text = createInterval(startDateString: dateLabel.text ?? "")
		default:
			return
		}
	}

    private func showGuests() {
        if guests.isEmpty {
            UIView.animate(withDuration: 0.5) {
                self.guestsViewHeightConstraint.constant = self.guestViewHeight + self.guestViewOffset
                self.guestsStackView.isHidden = true
                self.noGuestView.isHidden = false
            }
        } else {
            noGuestView.isHidden = true
            guestsStackView.isHidden = false
            configureStackView()
        }
    }

    private func configureStackView() {
        hideAllViews()
        for i in 0...guests.count - 1 {
            nameLabels[i].text = guests[i].fullName
            phoneLabels[i].text = guests[i].phone.addPassMask()
            guestViews[i].isHidden = false
        }
        UIView.animate(withDuration: 0.5) {
            let viewsHeight = self.guestViewHeight * CGFloat(self.guests.count)
            let offsetHeight = self.guestViewOffset * CGFloat((self.guests.count + 1))
            self.guestsViewHeightConstraint.constant = viewsHeight + offsetHeight
        }
    }

    private func hideAllViews() {
        for view in guestViews {
            view.isHidden = true
        }
    }

    private func addViewInStack(for guest: Guest) {
        let index = guests.count
        nameLabels[index].text = guest.fullName
        phoneLabels[index].text = guest.phone.addPassMask()//"phone add mask"//guest.phone.addPassMask()
        UIView.animate(withDuration: 0.5) {
            if self.guests.isEmpty {
                self.guestsViewHeightConstraint.constant = self.guestViewHeight + self.guestViewOffset
                self.noGuestView.isHidden = true
                self.guestsStackView.isHidden = false
                self.guestViews[index].isHidden = false
            } else {
                self.guestsViewHeightConstraint.constant += self.guestViewHeight + self.guestViewOffset
                self.guestViews[index].isHidden = false
            }
        }
        guests.append(guest)
    }

    private func createInterval(startDateString: String) -> String {
        if startDateString.count > 10 {
            return startDateString
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let startDate = dateFormatter.date(from: startDateString) ?? Date()
        let endDate = startDate.addingTimeInterval(60 * 60 * 24)
        let interval = "\(startDateString) - \(dateFormatter.string(from: endDate))"
        return interval
    }

    // MARK: - Actions

    @IBAction private func back(_ sender: Any) {
        self.createPassDelegate?.back()
    }

    @IBAction private func info(_ sender: Any) {
        self.createPassDelegate?.info()
    }

    @IBAction private func oneTimeType(_ sender: Any) {
        selectButton(at: .oneTime)
    }

    @IBAction private func oneDayType(_ sender: Any) {
        selectButton(at: .oneDay)
    }

    @IBAction private func temporaryType(_ sender: Any) {
        selectButton(at: .temporary)
    }

    @IBAction private func permanentType(_ sender: Any) {
        selectButton(at: .permanent)
    }
    
    @IBAction private func tapGuests(_ sender: Any) {
        for field in [commentTextField, carNumberTextField] {
            field?.resignFirstResponder()
        }
    }
    
    @IBAction private func needParkingDidChange(_ sender: Any) {
//        if type != .oneTime {
//            self.needParkingSwitch.setOn(false, animated: true)
//            self.createPassDelegate?.showParkingAlert()
//            return
//        }
        if needParkingSwitch.isOn {
            parkingDetailView.isHidden = false
            dateToNeedParkingConstraint.priority = UILayoutPriority(rawValue: 999)
            dateToParkingDetailTopConstraint.priority = UILayoutPriority(rawValue: 1000)
        } else {
            parkingDetailView.isHidden = true
            dateToNeedParkingConstraint.priority = UILayoutPriority(rawValue: 1000)
            dateToParkingDetailTopConstraint.priority = UILayoutPriority(rawValue: 999)
        }
    }

    @IBAction private func residentPayment(_ sender: Any) {
        residentButton.backgroundColor = Palette.goldColor
        guestButton.backgroundColor = unselectedBackgroundColor
        isResidentPay = true
    }

    @IBAction private func guestPayment(_ sender: Any) {
        residentButton.backgroundColor = unselectedBackgroundColor
        guestButton.backgroundColor = Palette.goldColor
        isResidentPay = false
    }

    @IBAction private func chooseDate(_ sender: Any) {
        self.createPassDelegate?.chooseDate(interval: type == .temporary)
    }

    @IBAction private func chooseEntrance(_ sender: Any) {
        self.createPassDelegate?.chooseEntrance()
    }

    @IBAction private func orderThePass(_ sender: Any) {
        if guests.isEmpty {
            self.createPassDelegate?.showNoGuestsError()
            return
        }
        if needParkingSwitch.isOn {
            if let text = carNumberTextField.text,
            text.isEmpty {
                self.createPassDelegate?.showNoCarDataError()
                return
            }
        }
        createPassButton.startButtonLoadingAnimation()
        self.createPassDelegate?.createPass(type: type)
        if needParkingSwitch.isOn && type == .oneTime {
            self.createPassDelegate?.createParking(carNumber: carNumberTextField.text ?? "", guest: guests[0], isResidentPay: residentButton.isSelected)
        }
    }
    
    func loadingDone() {
        createPassButton.endButtonLoadingAnimation(defaultTitle: "Заказать пропуск")
    }

    @IBAction private func addGuest(_ sender: Any) {
        if guests.count >= maxGuestsAmount {
            self.createPassDelegate?.showGuestsError()
            return
        }
        self.createPassDelegate?.needAddGuest()
    }

    @IBAction private func deleteGuest(_ sender: Any) {
        if let view = sender as? UIView {
            let index = view.tag % 10
            guests.remove(at: index)
            self.createPassDelegate?.deleteGuest(at: index)
        }
        showGuests()
    }
}

extension CreatePassView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
