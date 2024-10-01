final class PassListGiveMeTableViewCell: UITableViewCell {
    static var reuseIdentifier: String { String(describing: self) }

    
    @IBOutlet weak var contentViewCell: RoundedView!
    @IBOutlet private weak var apartmentNumberLabel: UILabel!
    @IBOutlet private weak var dateLabel: LocalizableLabel!

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

    func setData(pass: IssuePass) {
        self.apartmentNumberLabel.text = "\(pass.floor)-\(pass.apartmentNumber)"
        showDescription(for: pass)
    }

    // swiftlint:disable force_unwrapping
    private func showDescription(for pass: IssuePass) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd.MM"
        switch pass.type {
        case .temporary:
            let dateString = dateFormatter.string(from: pass.endDate!)
            dateLabel.text = "\(pass.typeDescription) · \(Localization.localize("pass.before")) \(dateString)"
        default:
            let dateString = dateFormatter.string(from: pass.startDate)
            dateLabel.text = "\(pass.typeDescription) · \(dateString)"
        }
    }
}
