import UIKit

final class ConciergeCloseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentBackgroundView: RoundedView!
    
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var applicationNumber: UILabel!
    @IBOutlet private weak var dateAndGuestsLabel: UILabel!
    @IBOutlet private weak var unreadIndicator: LocalizableLabel!
    
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

    func setData(item: Issue) {
        //self.backgroundColor = UIColor(hex: 0x313131)
        typeImageView.image = UIImage(named: item.imageName)
        self.statusLabel.textColor = item.statusColor
        statusLabel.text = item.statusDescription
        typeLabel.text = item.typeDesctiption
        applicationNumber.text = "\(Localization.localize("concierge.request")) № \(item.number)"
        let dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "HH:mm"
        dateAndGuestsLabel.text = item.createDateDescription //"\(item.executeDateDescription) · \(item.guestsDescription)"
        unreadIndicator.isHidden = item.channelUnreadComments == 0
        unreadIndicator.text = "\(item.channelUnreadComments)"
    }
}
