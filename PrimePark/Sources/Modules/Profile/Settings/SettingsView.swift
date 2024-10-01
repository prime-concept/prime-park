import UIKit

protocol SettingsViewDelegate: class {
    func changeLanguage()
    func logout()
    func back()
    func deleteUser()
}
//swiftlint:disable all
final class SettingsView: UIView {
    @IBOutlet weak var titleLabel: LocalizableLabel!
    @IBOutlet weak var languageLabel: LocalizableLabel!
    @IBOutlet weak var outLabel: LocalizableLabel!
    @IBOutlet weak var productVersionLabel: UILabel!
    
    private weak var delegate: SettingsViewDelegate?
    
    // MARK: - Init

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

    // MARK: - Public API

    func setDelegate(_ delegate: SettingsViewDelegate) {
        self.delegate = delegate
    }

    // MARK: - Actions

    @IBAction private func changeLanguage(_ sender: Any) {
        self.delegate?.changeLanguage()
    }

    @IBAction private func logout(_ sender: Any) {
        self.delegate?.logout()
    }
    
    @IBAction private func deleteUser(_ sender: Any?) {
        self.delegate?.deleteUser()
    }

    @IBAction private func back(_ sender: Any) {
        self.delegate?.back()
    }
}
