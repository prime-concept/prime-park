import UIKit

final class PassListIGiveTableViewCell: UITableViewCell {
    static var reuseIdentifier: String { String(describing: self) }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var contentBackgroundView: RoundedView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentBackgroundView.isLoadable = true
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    func setData(pass: IssuePass) {
        nameLabel.text = pass.fullName
        phoneLabel.text = pass.phone
        showDescription(for: pass)
    }

    // swiftlint:disable force_unwrapping
    private func showDescription(for pass: IssuePass) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd.MM"
        if let date = (pass.type == .temporary) ? pass.endDate : pass.createdAt {
            switch pass.type {
            case .temporary:
                let dateString = dateFormatter.string(from: date)
                descriptionLabel.text = "\(pass.typeDescription) · \(Localization.localize("pass.before")) \(dateString)"
            default:
                let dateString = dateFormatter.string(from: date)
                if pass.type == .permanent {
                    descriptionLabel?.text = pass.typeDescription
                } else {
                    descriptionLabel.text = "\(pass.typeDescription) · \(dateString)"
                }
            }
        }
    }
}
