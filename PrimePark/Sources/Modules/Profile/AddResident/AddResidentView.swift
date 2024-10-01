protocol AddResidentViewProtocol: class {
    func showInfo()
    func addResident(_ resident: Resident)
    func showError()
    func openContastBook()
    func back()
}

final class AddResidentView: UIView {
    @IBOutlet private weak var inhabitantButton: LocalizableButton!
    @IBOutlet private weak var brigadierButton: LocalizableButton!
    @IBOutlet private weak var firstNameTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var lastNameTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var middleNameTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var phoneTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet weak var createResidentButton: LocalizableButton!
    @IBOutlet private weak var scrollView: UIScrollView!

    private weak var delegate: AddResidentViewProtocol?
    private let unselectedBackgroundColor = UIColor(hex: 0x606060).withAlphaComponent(0.4)
    private var roleButtonsArray: [UIButton] = []
    private var currentRole: Role = .cohabitant
    private var textFields: [UITextField] = []

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
        roleButtonsArray = [inhabitantButton, brigadierButton]
        selectButton(at: 0)
        textFields = [firstNameTextField, lastNameTextField, middleNameTextField, phoneTextField]
        for textField in textFields {
            textField.delegate = self
        }
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func addDelegate(_ delegate: AddResidentViewProtocol) {
        self.delegate = delegate
    }

    func setData(name: String?, surname: String?, patronymic: String?, phone: String?) {
        if let name = name {
            self.firstNameTextField.text = name
        }
        if let surname = surname {
            self.lastNameTextField.text = surname
        }
        if let patronymic = patronymic {
            self.middleNameTextField.text = patronymic
        }
        if let phone = phone {
            self.phoneTextField.text = phone
        }
    }

    // MARK: - Private API

    private func selectButton(at index: Int) {
        for button in roleButtonsArray {
            button.backgroundColor = unselectedBackgroundColor
        }
        roleButtonsArray[index].backgroundColor = Palette.goldColor
    }

    @objc
    func adjustForKeyboard(notification: Notification) {
        guard let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        //let keyboardHeight = frameValue.cgRectValue.size.height
        let scrollViewRect: CGRect = self.convert(scrollView.frame, from: scrollView.superview)
        let hiddenScrollViewRect: CGRect = scrollViewRect.intersection(frameValue.cgRectValue)

        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: hiddenScrollViewRect.size.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    // MARK: - Actions

    @IBAction private func showContactBook(_ sender: Any) {
        self.delegate?.openContastBook()
    }

    @IBAction private func cohabitantDidTap(_ sender: Any) {
        currentRole = .cohabitant
        selectButton(at: 0)
    }

    @IBAction private func brigadierDidTap(_ sender: Any) {
        currentRole = .brigadier
        selectButton(at: 1)
    }

    @IBAction private func guestDidTap(_ sender: Any) {
        currentRole = .guest
        selectButton(at: 2)
    }

    @IBAction private func addResident(_ sender: Any) {
        if let firstName = firstNameTextField.text,
            !firstName.isEmpty,
            let lastName = lastNameTextField.text,
            !lastName.isEmpty,
            let phone = phoneTextField.text,
            !phone.isEmpty {
            createResidentButton.startButtonLoadingAnimation()
            let resident = Resident(name: firstName, surname: lastName, patronymic: middleNameTextField.text, phone: phone, role: currentRole.rawValue)
            self.delegate?.addResident(resident)
            return
        }
        self.delegate?.showError()
    }

    @IBAction private func back(_ sender: Any) {
        self.delegate?.back()
    }
    
    @IBAction func resignTextFields(_ sender: Any) {
        for textField in self.textFields {
            textField.resignFirstResponder()
        }
    }
}

extension AddResidentView {
    func loadingDone() {
        createResidentButton.endButtonLoadingAnimation(defaultTitle: "Добавить")
    }
}

extension AddResidentView: UITextFieldDelegate {
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

