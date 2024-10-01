import UIKit

// swiftlint:disable trailing_whitespace

protocol ProfileViewDelegate: class {
    func openSettings()
    func showApartments(_ user: User?, currentRoom: Room?)
    func showPasses()
    func showResidents()
    func showLawInfo()
    func changeApartment()
    func chooseImage()
}

final class ProfileView: UIView {
    private weak var delegate: ProfileViewDelegate?
    private var user: User?
    private var currentRoom: Room?
    
    private let darkColor = UIColor(hex: 0x121212)
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.0, y: 0.9)
        layer.endPoint = CGPoint(x: 0.0, y: 0.0)

        layer.colors = [
            self.darkColor.withAlphaComponent(0).cgColor,
            self.darkColor.withAlphaComponent(1).cgColor
        ]

         return layer
    }()
    
    @IBOutlet weak var roundedProfileImageView: RoundedImageView!
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var apartmentNumberLabel: UILabel!
    @IBOutlet var primeParkSegmentedControl: PrimeSegmentControl!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var statusLabel: LocalizableLabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var residentLabel: UILabel!
    @IBOutlet private weak var amountOfResidentsLabel: UILabel!
    @IBOutlet private weak var amountOfResidentsView: RoundedView!
    @IBOutlet var habitantAccess: [LayerBackgroundView]!
    @IBOutlet var primeView: UIView!
    @IBOutlet var userInfoView: UIView!
    @IBOutlet var secondaryInfoView: UIView!
    @IBOutlet var backgroundImage: UIImageView!
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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Public API

    func commonInit() {
        changeAccess(LocalAuthService.shared.apartment)
        primeParkSegmentedControl.delegate = self
        self.gradientLayer.frame = self.backgroundImage.frame
        self.backgroundImage.layer.mask = self.gradientLayer
    }

    func setDelegate(_ delegate: ProfileViewDelegate) {
        self.delegate = delegate
    }

    func setUser(_ user: User?, room: Room?) {
        self.user = user
        currentRoom = room
        reloadInfoAboutUser()
    }
    
    func setUser(_ user: User) {
        self.user = user
        reloadInfoAboutUser()
    }
    
    func setResidentCount(_ count: Int) {
        amountOfResidentsLabel.text = "+\(count - 1)"
    }

    // MARK: - Private API

    private func reloadInfoAboutUser() {
        guard let user = self.user, let room = currentRoom else {
            //всё в нил поставить
            return
        }
        //apartmentNumberLabel.text = "\(room.floor)-\(room.apartmentNumber)"
        nameLabel.text = user.getFullName()
        statusLabel.text = currentRoom?.roleDescription
        phoneLabel.text = "+\(user.phone.addPhoneMaskForProfile())"
        emailLabel.text = user.email
        residentLabel.text = user.shortFullName
//        amountOfResidentsLabel.text = "+\(user.defaultRoom.)"
        
        if let url = URL(string: user.avatar) {
            self.roundedProfileImageView.imageView.loadImage(from: url)
        }
    }
    
    private func changeAccess(_ currentRoom: Room?) {
        guard let room = currentRoom else { return }
        switch room.getRole {
        case .resident:
            habitantAccess.forEach { $0.isHidden = false }
        case .cohabitant:
            habitantAccess.forEach { $0.isHidden = true }
        case .brigadier:
            habitantAccess.forEach { $0.isHidden = true }
        case .guest:
            habitantAccess.forEach { $0.isHidden = true }
        }
    }

    // MARK: - Actions

    @IBAction private func changeApartment(_ sender: Any) {
        self.delegate?.changeApartment()
    }

    @IBAction private func showPhone(_ sender: Any) {
        print("phone")
    }

    @IBAction private func showEmail(_ sender: Any) {
    }

    @IBAction private func showApartments(_ sender: Any) {
        self.delegate?.showApartments(user, currentRoom: currentRoom)
    }
    
    @IBAction private func showPasses(_ sender: Any) {
        delegate?.showPasses()
    }

    @IBAction private func showResidents(_ sender: Any) {
        if let currentRoom = currentRoom {
            if currentRoom.getRole == .resident {
                delegate?.showResidents()
            }
        }
    }

    @IBAction private func showLawInfo(_ sender: Any) {
        self.delegate?.showLawInfo()
    }

    @IBAction private func showSettings(_ sender: Any) {
        self.delegate?.openSettings()
    }

    @IBAction private func addPhoto(_ sender: Any) {
        delegate?.chooseImage()
    }
}

extension ProfileView: ApplyingLabelProtocol {
    func applyRoomFormat(format: String, currentRoom: Room) {
        changeAccess(currentRoom)
        self.apartmentNumberLabel.text = format
        self.currentRoom = currentRoom
        self.statusLabel.text = currentRoom.roleDescription
    }
}

extension ProfileView: PrimeSegmentControlDelegate {
    func didChange(index: Int) {
        if index == 0 {
            primeView.isHidden = true
            userInfoView.isHidden = false
            secondaryInfoView.isHidden = false
        } else {
            primeView.isHidden = false
            userInfoView.isHidden = true
            secondaryInfoView.isHidden = true
        }
    }
}
