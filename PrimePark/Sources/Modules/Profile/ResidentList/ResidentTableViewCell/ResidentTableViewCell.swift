extension Notification.Name {
    static let needDeleteGuest = Notification.Name("needDeleteGuest")
}

final class ResidentTableViewCell: UITableViewCell {
    static var reuseIdentifier: String { String(describing: self) }
    private var resident: Resident?

    @IBOutlet weak var contentViewCell: RoundedView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var roleLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentViewCell.isSkeletonable = true
        contentViewCell.clipsToBounds = true
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    func setData(resident: Resident) {
        nameLabel.text = resident.shortFullName
        roleLabel.text = resident.roleDescription
        print(resident.roleDescription)
        let showResidentButton = resident.getRole == .brigadier || resident.getRole == .guest || resident.getRole == .cohabitant
        deleteButton.isHidden = !showResidentButton
        self.resident = resident
    }

    @IBAction private func deleteResident(_ sender: Any) {
        guard let resident = self.resident else { return }
        NotificationCenter.default.post(name: .needDeleteGuest, object: nil, userInfo: ["resident": resident])
    }
}
