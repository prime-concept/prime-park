protocol AddGuestViewProtocol: class {
    func addGuest(name: String, surname: String, patronymic: String?, phone: String)
    func showError()
    func openContastBook()
    func back()
}

final class AddGuestView: UIView {
    private weak var delegate: AddGuestViewProtocol?
    private var textFields: [UITextField] = []
    private var recentGuests: [Guest] = []

    @IBOutlet private weak var nameTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var surnameTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var patronymicTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var phoneTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var addGuestButton: LocalizableButton!
    @IBOutlet private weak var recentGuestsStackView: UIStackView!
    @IBOutlet weak var recentGuestView: UIView!
    @IBOutlet weak var recentGuestHeightConstraint: NSLayoutConstraint!

    // MARK: - Initialization

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
        textFields = [nameTextField, surnameTextField, patronymicTextField, phoneTextField]
        for textField in textFields {
            textField.delegate = self
        }
    }

    func addDelegate(_ delegate: AddGuestViewProtocol) {
        self.delegate = delegate
    }

    func setData(name: String?, surname: String?, patronymic: String?, phone: String?) {
        if let name = name {
            self.nameTextField.text = name
        }
        if let surname = surname {
            self.surnameTextField.text = surname
        }
        if let patronymic = patronymic {
            self.patronymicTextField.text = patronymic
        }
        if let phone = phone {
            self.phoneTextField.text = phone
        }
    }

    // swiftlint:disable force_unwrapping
    func addRecentGuests(_ guests: [Guest]) {
        recentGuests = guests
        if guests.isEmpty {
            recentGuestHeightConstraint.constant = 0
            recentGuestView.isHidden = true
        }
        for guest in guests {
            let button = UIButton(type: .system)
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            button.backgroundColor = .clear
            //button.setTitleColor(.white, for: .normal)
            button.setTitle(guest.shortcutName, for: .normal)
            let attrTitle = NSAttributedString(string: guest.shortcutName, attributes: [
                NSAttributedString.Key.font: UIFont.primeParkFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
            button.setAttributedTitle(attrTitle, for: .normal)
            button.layer.borderColor = UIColor(hex: 0x606060).withAlphaComponent(0.4).cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 13
            button.tag = 500 + guests.firstIndex(of: guest)!
            button.addTarget(self, action: #selector(recentGuestDidTap(button:)), for: .touchUpInside)

            recentGuestsStackView.addArrangedSubview(button)
        }
    }

    @objc
    private func recentGuestDidTap(button: UIButton) {
        let index = button.tag - 500
        let guest = recentGuests[index]
        setData(name: guest.name, surname: guest.surname, patronymic: guest.patronymic, phone: guest.phone)
    }

    // MARK: - Actions

    @IBAction private func openContacts(_ sender: Any) {
        self.delegate?.openContastBook()
    }

    @IBAction private func add(_ sender: Any) {
        if let name = nameTextField.text,
            let surname = surnameTextField.text,
            let phone = phoneTextField.text {
            if name.isEmpty || surname.isEmpty || phone.isEmpty {
                self.delegate?.showError()
            } else {
                self.delegate?.addGuest(name: name, surname: surname, patronymic: patronymicTextField.text, phone: phone)
            }
        } else {
            self.delegate?.showError()
        }
    }

    @IBAction private func back(_ sender: Any) {
        self.delegate?.back()
    }
    
    @IBAction func resignTextField(_ sender: Any) {
        for textField in self.textFields {
            textField.resignFirstResponder()
        }
    }
}

extension AddGuestView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = textFields.firstIndex(of: textField) else {
            textField.resignFirstResponder()
            return true
        }
        if index == textFields.count - 1 {
            textField.resignFirstResponder()
            return true
        }
        textField.resignFirstResponder()
        textFields[index + 1].becomeFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === phoneTextField {
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            textField.text = format(with: .detectCountryCode(number: newString), phone: newString)
            return false
        }
        return true
    }
}
