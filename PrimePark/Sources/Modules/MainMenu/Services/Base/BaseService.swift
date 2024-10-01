//
//  BaseService.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 01.03.2021.
//
//swiftlint:disable all

protocol BaseServiceDelegate: ModalRouterSourceProtocol, AlertServiceProtocol {
    func close()
    func chooseServiceType()
    func order(type: String)
}


struct Service {
    enum ServiceType: Int {
		case wifi = 0
		case furniturePrimepark
        case repair
		case gsm
		case pantries
		case furniture
    }
    let imageName: String
    let titleName: String
    let subtitle: String
    let description: String
    let serviceTypes: [String]
}

class BaseService: UIView {
    
    // base
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet private weak var headerImage: UIImageView!
    @IBOutlet private weak var titleLabel: LocalizableLabel!
    @IBOutlet private weak var subtitleLabel: LocalizableLabel!
    @IBOutlet private weak var descriptionTextView: UITextView! {
        didSet {
            self.tapDescriptionTextView()
        }
    }
    @IBOutlet private weak var showHideArrowImage: UIImageView!
    
    @IBOutlet weak var serviceType: UIView!
    @IBOutlet weak var serviceTypeLabel: LocalizableLabel!
    @IBOutlet weak var order: LocalizableButton!
    
    @IBOutlet weak var componentContentView: UIView!
    
    @IBOutlet weak var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceConstraint: NSLayoutConstraint!
    
    private lazy var textViewHeight: CGFloat = {
        let newSize = descriptionTextView.sizeThatFits(CGSize(width: self.frame.size.width - 30, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }()
    
    private lazy var gradient: CAGradientLayer = {
        let tempGradient = CAGradientLayer()
        tempGradient.frame = descriptionTextView.bounds
        tempGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        tempGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        tempGradient.endPoint = CGPoint(x: 0.0, y: 0.9)
        return tempGradient
    }()

	private lazy var titleImageGradient: CAGradientLayer = {
		let tempGradient = CAGradientLayer()
		tempGradient.frame = self.headerImage.bounds
		tempGradient.colors = [
			UIColor.black.withAlphaComponent(0.5).cgColor, 
			UIColor.clear.cgColor,
			UIColor.black.withAlphaComponent(0.7).cgColor
		]
		tempGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
		tempGradient.endPoint = CGPoint(x: 0.0, y: 0.9)
		return tempGradient
	}()
    
    private let compressedTextViewHeight: CGFloat = 81.0
    private var textIsFull = false
    private var service: Service.ServiceType
    
    private weak var delegate: BaseServiceDelegate?
    
    init(
        service: Service.ServiceType,
        delegate: BaseServiceDelegate? = nil
    ) {
        self.service = service
        self.delegate = delegate
        super.init(frame: .zero)
        
        Bundle.main.loadNibNamed("BaseService", owner: self, options: nil)
        
        bounds = contentView.bounds
        
        addSubview(contentView)
        
        serviceTypeLabel.text = localizedWith(mockData[service.rawValue].serviceTypes.first ?? "nil")
        backgroundColor = Palette.blackColor
        
        switch service {
        case .repair, .furniturePrimepark, .furniture:
            serviceType.isHidden = true
        default:
            break
        }
        
        order.backgroundColor = Palette.goldColor

        setupData(service: mockData[service.rawValue])
    }
    
    func setupData(service: Service) {
		self.headerImage.layer.addSublayer(self.titleImageGradient)
		self.sendSubviewToBack(self.headerImage)

        headerImage.image = UIImage(named: service.imageName)
        titleLabel.text = localizedWith(service.titleName)
        subtitleLabel.text = localizedWith(service.subtitle)
        descriptionTextView.text = localizedWith(service.description)
        descriptionTextView.layer.mask = gradient
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func close(_ sender: Any) {
        delegate?.close()
    }
    
    @IBAction func tapDescription(_ sender: Any) {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.15) {
            if self.textIsFull {
                self.descriptionTextViewHeightConstraint.constant = self.compressedTextViewHeight
                self.descriptionTextView.layer.mask = self.gradient
                self.showHideArrowImage.isHighlighted = false
                self.textIsFull = false
            } else {
                self.descriptionTextViewHeightConstraint.constant = self.textViewHeight
                self.gradient.removeFromSuperlayer()
                self.showHideArrowImage.isHighlighted = true
                self.textIsFull = true
            }
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func chooseServiceType(_ sender: Any) {
        delegate?.chooseServiceType()
    }
    
    @IBAction func order(_ sender: Any) {
        switch service {
        case .wifi:
            call("+7(495)645-98-28")
        case .gsm:
            call("+7(495)1182640")
        case .pantries:
            call("+7(495)0254444")
        case .repair:
            call("+79302202389")
        case .furniturePrimepark:
            call("+79651733933")
		case .furniture:
			call("+74950253881")
        default:
            return
        }
    }
    
    func tapDescriptionTextView() {
        let recognizer = UITapGestureRecognizer()
        descriptionTextView.addGestureRecognizer(recognizer)
        recognizer.addTarget(self, action: #selector(didTapText(_:)))
    }
    
    @objc func didTapText(_ sender: Any) {
        if !self.textIsFull {
            self.descriptionTextViewHeightConstraint.constant = self.textViewHeight
            self.gradient.removeFromSuperlayer()
            self.showHideArrowImage.isHighlighted = true
            self.textIsFull = true
        }
    }

	override func layoutSubviews() {
		super.layoutSubviews()

		self.titleImageGradient.frame = self.headerImage.bounds
	}
}

extension BaseService {
    func call(_ companyPhone: String) {
        if let phone = URL(string: "tel://\(companyPhone)"),
            UIApplication.shared.canOpenURL(phone) {
            UIApplication.shared.open(phone)
        }
    }
}

extension BaseService {
    func stopLoading() {
        order.endButtonLoadingAnimation(defaultTitle: localizedWith("services.order.button"))
    }
}
