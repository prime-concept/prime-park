protocol CreateParkingViewProtocol: class {
    func back()
    func info()
    func chooseDate()
    func needAddGuest()
    func deleteGuest(at index: Int)
    func createParking(type: ParkingType, carNumber: String, carModel: String?, isResidentPay: Bool)
    func choosePayer(isResident: Bool)
    func chooseEntrance()
    func showGuestsError()
    func showEmptyDataError()
}

//swiftlint:disable all

final class CreateParkingView: UIView {
    @IBOutlet private weak var carNumberTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var carModelTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet weak var payingModule: UIView!
    @IBOutlet private weak var residentPayButton: LocalizableButton!
    @IBOutlet private weak var guestPayButton: LocalizableButton!
    @IBOutlet private weak var dateOfVisitLabel: UILabel!
    @IBOutlet private weak var entranceLabel: LocalizableLabel!
    @IBOutlet private weak var commentTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var noGuestView: RoundedView!
    @IBOutlet private weak var guestsStackView: UIStackView!
    @IBOutlet weak var createParkingButton: LocalizableButton!
    @IBOutlet private var guestViews: [RoundedView]!
    @IBOutlet private var nameLabels: [UILabel]!
    @IBOutlet private var phoneLabels: [UILabel]!
    @IBOutlet private weak var guestViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var carModelBottomToDateTop: NSLayoutConstraint!
    @IBOutlet weak var parkingBottomToDateTop: NSLayoutConstraint!
    
    private weak var createParkingViewDelegate: CreateParkingViewProtocol?
    private var guests: [Guest] = []
    private let unselectedBackgroundColor = UIColor(hex: 0x606060).withAlphaComponent(0.4)
    private var isResidentPay = true
    private let maxGuestsAmount = 5
    private var type: ParkingType = .onetime
    private let guestViewHeight: CGFloat = 67
    private let guestViewOffset: CGFloat = 5

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
        var insets = scrollView.contentInset
        insets.bottom += 105
        scrollView.contentInset = insets
        for field in [commentTextField, carNumberTextField, carModelTextField] {
            field?.delegate = self
        }
        self.carNumberTextField.autocapitalizationType = .allCharacters
        showGuests()
        changeAccess(LocalAuthService.shared.apartment?.getRole ?? .resident)
    }

    func addDelegate(_ delegate: CreateParkingViewProtocol) {
        self.createParkingViewDelegate = delegate
    }

    func addGuestsArray(_ array: [Guest]) {
        self.guests = array
        showGuests()
    }

    func addGuest(_ man: Guest) {
        addViewInStack(for: man)
    }

    func setChoosenDate(date: String) {
        self.dateOfVisitLabel.text = date
    }
    
    func setEntrance(entrance: Entrance) {
        self.entranceLabel.text = entrance.localizedName
    }

	func setCarModel(_ carModel: String) {
		self.carModelTextField.text = carModel
	}

	func setCarNumber(_ carNumber: String) {
		self.carNumberTextField.text = carNumber
	}
    
    func changeAccess(_ role: Role) {
        switch role {
        case .resident:
            carModelBottomToDateTop.priority = UILayoutPriority(999)
            parkingBottomToDateTop.priority = UILayoutPriority(1000)
            isResidentPay = true
        case .cohabitant:
            carModelBottomToDateTop.priority = UILayoutPriority(1000)
            parkingBottomToDateTop.priority = UILayoutPriority(999)
            isResidentPay = false
        case .brigadier:
            carModelBottomToDateTop.priority = UILayoutPriority(1000)
            parkingBottomToDateTop.priority = UILayoutPriority(999)
            isResidentPay = false
        default:
            carModelBottomToDateTop.priority = UILayoutPriority(999)
            parkingBottomToDateTop.priority = UILayoutPriority(1000)
            isResidentPay = true
        }
    }

    // MARK: - Private API

    private func showGuests() {
        if guests.isEmpty {
            UIView.animate(withDuration: 0.5) {
                self.guestViewHeightConstraint.constant = self.guestViewHeight + self.guestViewOffset
                self.guestsStackView.isHidden = true
                self.noGuestView.isHidden = false
            }
			return
        }

		noGuestView.isHidden = true
		guestsStackView.isHidden = false
		configureStackView()
    }

    private func configureStackView() {
        hideAllViews()
        for i in 0...guests.count - 1 {
            nameLabels[i].text = "\(guests[i].name) \(guests[i].surname)"
            phoneLabels[i].text = guests[i].phone
            guestViews[i].isHidden = false
        }
        UIView.animate(withDuration: 0.5) {
            let viewsHeight = self.guestViewHeight * CGFloat(self.guests.count)
            let offsetHeight = self.guestViewOffset * CGFloat((self.guests.count + 1))
            self.guestViewHeightConstraint.constant = viewsHeight + offsetHeight
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
        phoneLabels[index].text = guest.phone

        UIView.animate(withDuration: 0.5) {
            if self.guests.isEmpty {
                self.guestViewHeightConstraint.constant = self.guestViewHeight + self.guestViewOffset
                self.noGuestView.isHidden = true
                self.guestsStackView.isHidden = false
                self.guestViews[index].isHidden = false
            } else {
                self.guestViewHeightConstraint.constant += self.guestViewHeight + self.guestViewOffset
                self.guestViews[index].isHidden = false
            }
        }

        guests.append(guest)
    }

    // MARK: - Actions
    
    @IBAction func tapTitleResignTextFields(_ sender: Any) {
        for field in [commentTextField, carNumberTextField, carModelTextField] {
            field?.resignFirstResponder()
        }
    }

    @IBAction private func back(_ sender: Any) {
        self.createParkingViewDelegate?.back()
    }

    @IBAction private func info(_ sender: Any) {
        self.createParkingViewDelegate?.info()
    }

    @IBAction private func residentPay(_ sender: Any) {
        residentPayButton.backgroundColor = Palette.goldColor
        guestPayButton.backgroundColor = unselectedBackgroundColor
        isResidentPay = true
        createParkingViewDelegate?.choosePayer(isResident: isResidentPay)
    }

    @IBAction private func guestPay(_ sender: Any) {
        residentPayButton.backgroundColor = unselectedBackgroundColor
        guestPayButton.backgroundColor = Palette.goldColor
        isResidentPay = false
        createParkingViewDelegate?.choosePayer(isResident: isResidentPay)
    }
    //swiftlint:disable all
    @IBAction private func chooseDate(_ sender: Any) {
        self.createParkingViewDelegate?.chooseDate()
    }
    
    @IBAction func chooseEntrance(_ sender: Any) {
        createParkingViewDelegate?.chooseEntrance()
    }

    @IBAction private func addGuest(_ sender: Any) {
        if guests.count >= maxGuestsAmount {
            self.createParkingViewDelegate?.showGuestsError()
            return
        }
        self.createParkingViewDelegate?.needAddGuest()
    }

    @IBAction private func deleteGuest(_ sender: Any) {
        if let view = sender as? UIView {
            let index = view.tag % 10
            guests.remove(at: index)
            self.createParkingViewDelegate?.deleteGuest(at: index)
        }
        showGuests()
    }

    @IBAction private func orderTheParking(_ sender: Any) {
        if guests.isEmpty && ((carNumberTextField.text?.isEmpty) != nil) {
            self.createParkingViewDelegate?.showEmptyDataError()
        } else {
            self.createParkingButton.startButtonLoadingAnimation()
            self.createParkingViewDelegate?.createParking(type: .onetime, carNumber: carNumberTextField.text ?? "", carModel: carModelTextField.text, isResidentPay: isResidentPay)
        }
    }
    
    func loadingDone() {
        createParkingButton.endButtonLoadingAnimation(defaultTitle: localizedWith("createParking.parkingOrderButton.title"))
    }
}

extension CreateParkingView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
