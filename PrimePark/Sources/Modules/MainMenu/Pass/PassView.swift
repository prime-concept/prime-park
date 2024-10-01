protocol PassViewProtocol: class {
    func repeatPass()
    func revokePass()
}
//swiftlint:disable multiline_literal_brackets
final class PassView: UIView {
    private weak var delegate: PassViewProtocol?
    private var pass: IssuePass?

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
        guard let pass = pass else { return }
        revokeButton.isHidden = !pass.active
    }

    func addDelegate(_ delegate: PassViewProtocol, pass: IssuePass) {
        self.delegate = delegate
        self.pass = pass
        showData()
    }

    // MARK: - Private API

    func showData() {
        guard let pass = pass else { return }

        titleLabel.text = "\(pass.typeDescription) \(Localization.localize("pass.pass"))"
        entranceLabel.text = localizedWith(pass.isService ? "createPass.entrance.service" : "createPass.entrance.front")

        print(pass.isService)

        dateLabel.text = pass.createdDateMedium
		
        if pass.type == .permanent {
            dateLabel.text = ""
        }

        if pass.type == .temporary {
            dateLabel.text = "\(pass.createdDateMedium) - \(pass.endDateMedium)"
        }

        nameLabel.text = pass.fullName
        phoneLabel.text = pass.phone.addPassMask()
    }

    // MARK: - Actions

    @IBAction private func repeatPass(_ sender: Any) {
        delegate?.repeatPass()
    }

    @IBAction private func revoke(_ sender: Any) {
        revokeButton.startButtonLoadingAnimation()
        repeatButton.isUserInteractionEnabled = false
        delegate?.revokePass()
    }
}
