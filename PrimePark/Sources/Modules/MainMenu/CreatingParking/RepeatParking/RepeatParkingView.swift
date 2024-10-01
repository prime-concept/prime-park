protocol RepeatParkingViewProtocol: class {
	func repeatParking()
}

//swiftlint:disable multiline_literal_brackets
final class RepeatParkingView: UIView {
    private weak var delegate: RepeatParkingViewProtocol?
    private var parking: Parking?

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var entranceLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var personImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var repeatButton: LocalizableButton!
    @IBOutlet private weak var revokeButton: LocalizableButton!
	
    // MARK: - Public API

    func commonInit() {
        revokeButton.isHidden = true
    }

    func addDelegate(_ delegate: RepeatParkingViewProtocol, parking: Parking) {
        self.delegate = delegate
        self.parking = parking
        showData()
    }

    // MARK: - Private API

    func showData() {
        guard let parking = parking else { return }

		titleLabel.text = parking.typeDescription
		let car = parking.carModel + " • " + parking.carNumber
		entranceLabel.text = car == " • " ? "•" : car

		dateLabel.text = parking.createdDateMedium

		nameLabel.text = parking.name
		phoneLabel.text = parking.phone
    }

    // MARK: - Actions

    @IBAction private func repeatPass(_ sender: Any) {
        delegate?.repeatParking()
    }

    @IBAction private func revoke(_ sender: Any) {
		
    }
}
