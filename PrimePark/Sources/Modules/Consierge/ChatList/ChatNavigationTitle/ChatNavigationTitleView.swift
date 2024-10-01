import UIKit

final class ChatNavigationTitleView: UIView {
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var numberLabel: UILabel!

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

    func setData(item: Issue) {
        typeLabel.text = item.typeDesctiption
        numberLabel.text = "\(Localization.localize("concierge.request")) № \(item.number)"
    }
}
