import UIKit

final class ParkingCell: UITableViewCell {
    static var reuseIdentifier: String { String(describing: self) }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var carNumberLabel: UILabel!
    @IBOutlet private weak var backgroundContentView: LayerBackgroundView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundContentView.isLoadable = true
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    func setData(parking: Parking) {
        nameLabel.text = parking.name
        phoneLabel.text = parking.phone
        carNumberLabel.text = parking.carNumber
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd.MM"
        descriptionLabel.text = dateFormatter.string(from: parking.created)
    }
}
