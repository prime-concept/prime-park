import UIKit

protocol ChooseParkViewDelegate: class {
    func parkDidChoose(park: Int)
}

private enum ParkType: Int {
    case mirabel
    case victory
    case rigen
    case imperial
    case gorky
    case hyde
    case central
    case petrovsky
    case queen
    case apple
    case prime
    case cherry
}

final class ChooseParkView: UIView {
    private weak var delegate: ChooseParkViewDelegate?
    private var choosenPark: ParkType = .mirabel
    private var parkLabelsArray: [UILabel] = []
    private var checkmarksArray: [UIImageView] = []

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var mirableLabel: UILabel!
    @IBOutlet private weak var mirableCheckmark: UIImageView!
    @IBOutlet private weak var victoryLabel: UILabel!
    @IBOutlet private weak var victoryCheckmark: UIImageView!
    @IBOutlet private weak var rigenLabel: UILabel!
    @IBOutlet private weak var rigenCheckmark: UIImageView!
    @IBOutlet private weak var imperialLabel: UILabel!
    @IBOutlet private weak var imperialCheckmark: UIImageView!
    @IBOutlet private weak var gorkyLabel: UILabel!
    @IBOutlet private weak var gorkyCheckmark: UIImageView!
    @IBOutlet private weak var hydeLabel: UILabel!
    @IBOutlet private weak var hydeCheckmark: UIImageView!
    @IBOutlet private weak var centralLabel: UILabel!
    @IBOutlet private weak var centralCheckmark: UIImageView!
    @IBOutlet private weak var petrovskyLabel: UILabel!
    @IBOutlet private weak var petrovskyCheckmark: UIImageView!
    @IBOutlet private weak var royalLabel: UILabel!
    @IBOutlet private weak var royalCheckmark: UIImageView!
    @IBOutlet private weak var appleLabel: LocalizableLabel!
    @IBOutlet private weak var appleCheckmark: UIImageView!
    @IBOutlet private weak var primeLabel: LocalizableLabel!
    @IBOutlet private weak var primeCheckmark: UIImageView!
    @IBOutlet private weak var cherryLabel: LocalizableLabel!
    @IBOutlet private weak var cherryCheckmark: UIImageView!
    @IBOutlet private weak var callSecurityButton: UIButton!

    init(delegate: ChooseParkViewDelegate?) {
        self.delegate = delegate
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

    func setDelegate(delegate: ChooseParkViewDelegate) {
        self.delegate = delegate
    }

    func commonInit() {
        layer.cornerRadius = 15
        parkLabelsArray = [mirableLabel, victoryLabel, rigenLabel, imperialLabel, gorkyLabel, hydeLabel, centralLabel, petrovskyLabel, royalLabel, appleLabel, primeLabel, cherryLabel]
        checkmarksArray = [
            mirableCheckmark,
            victoryCheckmark,
            rigenCheckmark,
            imperialCheckmark,
            gorkyCheckmark,
            hydeCheckmark,
            centralCheckmark,
            petrovskyCheckmark,
            royalCheckmark,
            appleCheckmark,
            primeCheckmark,
            cherryCheckmark
        ]
        callSecurityButton.backgroundColor = Palette.goldColor
        callSecurityButton.isEnabled = false
        callSecurityButton.isHighlighted = true
        
        clearAllHighlight()
    }

    private func clearAllHighlight() {
        for label in parkLabelsArray {
            label.textColor = Palette.darkLightColor
        }
        for checkMark in checkmarksArray {
            checkMark.isHidden = true
        }
    }
    private func selectPark() {
        clearAllHighlight()
        parkLabelsArray[choosenPark.rawValue].textColor = .white
        checkmarksArray[choosenPark.rawValue].isHidden = false
        callSecurityButton.isEnabled = true
        callSecurityButton.isHighlighted = false
    }

    @IBAction private func mirabelPark(_ sender: Any) {
        choosenPark = .mirabel
        selectPark()
    }

    @IBAction private func victoryPark(_ sender: Any) {
        choosenPark = .victory
        selectPark()
    }

    @IBAction private func rigenPark(_ sender: Any) {
        choosenPark = .rigen
        selectPark()
    }

    @IBAction private func imperialPark(_ sender: Any) {
        choosenPark = .imperial
        selectPark()
    }

    @IBAction private func gorkyPark(_ sender: Any) {
        choosenPark = .gorky
        selectPark()
    }

    @IBAction private func hydePark(_ sender: Any) {
        choosenPark = .hyde
        selectPark()
    }

    @IBAction private func centralPark(_ sender: Any) {
        choosenPark = .central
        selectPark()
    }

    @IBAction private func petrovskyPark(_ sender: Any) {
        choosenPark = .petrovsky
        selectPark()
    }

    @IBAction private func royalPark(_ sender: Any) {
        choosenPark = .queen
        selectPark()
    }

    @IBAction private func applePark(_ sender: Any) {
        choosenPark = .apple
        selectPark()
    }

    @IBAction private func primePark(_ sender: Any) {
        choosenPark = .prime
        selectPark()
    }

    @IBAction private func cherryPark(_ sender: Any) {
        choosenPark = .cherry
        selectPark()
    }

    @IBAction private func callSecurity(_ sender: Any) {
        self.delegate?.parkDidChoose(park: self.choosenPark.rawValue + 1)
    }
}
