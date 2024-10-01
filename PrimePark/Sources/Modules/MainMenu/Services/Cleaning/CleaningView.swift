import UIKit

protocol CleaningViewDelegate: class {
    func setNowDate(isNow: Bool)
    func сleaningDidChoose(in date: Date)
    func closeController()
    func presentParameters()
    func openCalendar()
    func chooseTime(isStart: Bool)
    func order(text: String?)
    func setTime(time: Date, isStart: Bool)
}

private enum CleaningType: Int {
    case springСleaning
    case cleaningAfterRenovation
    case maintenanceCleaning
    case windowCleaning
    case other
}

final class CleaningView: UIView {
    private weak var delegate: CleaningViewDelegate?
    private var choosenType: CleaningType = .springСleaning
    private let unselectedBackgroundColor = UIColor(hex: 0x606060).withAlphaComponent(0.4)
    private var lastPointY: CGFloat = 0
    private let compressedTextViewHeight: CGFloat = 81.0
    private var textIsFull = false
    private lazy var textViewHeight: CGFloat = {
        let newSize = aboutTextView.sizeThatFits(CGSize(width: self.frame.size.width - 30, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }()
    private lazy var gradient: CAGradientLayer = {
        let tempGradient = CAGradientLayer()
        tempGradient.frame = aboutTextView.bounds
        tempGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        tempGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        tempGradient.endPoint = CGPoint(x: 0.0, y: 0.9)
        return tempGradient
    }()

	private lazy var titleImageGradient: CAGradientLayer = {
		let tempGradient = CAGradientLayer()
		tempGradient.frame = titleImageView.bounds
		tempGradient.colors = [
			UIColor.black.withAlphaComponent(0.5).cgColor,
			UIColor.clear.cgColor,
			UIColor.black.withAlphaComponent(0.7).cgColor
		]
		tempGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
		tempGradient.endPoint = CGPoint(x: 0.0, y: 0.9)
		return tempGradient
	}()

	@IBOutlet weak var titleLabel: LocalizableLabel!
	@IBOutlet weak var titleImageView: UIImageView!
	@IBOutlet weak var closeButton: LocalizableButton!
	@IBOutlet private weak var aboutTextView: UITextView!
    @IBOutlet private weak var serviceNameLabel: LocalizableLabel!
    @IBOutlet private weak var enterDescriptionTextField: TextFieldWithCustomPlaceholder!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet weak var timeToTextField: UITextField!
    @IBOutlet weak var timeFromTextField: UITextField!
    @IBOutlet private weak var nowButton: LocalizableButton!
    @IBOutlet private weak var otherDayButton: LocalizableButton!
    @IBOutlet private weak var descriptionView: UIView!
    @IBOutlet private weak var dateView: UIView!
    @IBOutlet private weak var timeView: UIView!
    @IBOutlet private weak var optionalTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var optionalBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var requiredTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var requiredBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var showTextImageView: UIImageView!

    private lazy var timeFromDatePicker = TimeDatePicker(minDate: "00:00", maxDate: "24:00")
    private lazy var timeToDatePicker = TimeDatePicker(minDate: "00:00", maxDate: "24:00")
    
    private lazy var timeFromToolbar: TimePickerToolBar = {
        let toolbar = TimePickerToolBar(label: Localization.localize("timePicker.startTime.title"))
        let doneAction = UIBarButtonItem(
            title: Localization.localize("createParking.choodeGuestButton.title"),
            style: .plain,
            target: self,
            action: #selector(self.onStartSelectButtonTap)
        )
        let cancelAction = UIBarButtonItem(customView: toolbar.titleLabel)
        toolbar.items = [cancelAction, toolbar.spaceButton, doneAction]
        toolbar.sizeToFit()

        return toolbar
    }()
    
    private lazy var timeToToolbar: TimePickerToolBar = {
        let toolbar = TimePickerToolBar(label: Localization.localize("timePicker.endTime.title"))
        let doneAction = UIBarButtonItem(
            title: Localization.localize("createParking.choodeGuestButton.title"),
            style: .plain,
            target: self,
            action: #selector(self.onEndSelectButtonTap)
        )
        let cancelAction = UIBarButtonItem(customView: toolbar.titleLabel)
        toolbar.items = [cancelAction, toolbar.spaceButton, doneAction]
        toolbar.sizeToFit()

        return toolbar
    }()
    
    init(delegate: CleaningViewDelegate?) {
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

    // MARK: - Public API

    func commonInit() {
		self.titleImageView.layer.addSublayer(self.titleImageGradient)
		self.sendSubviewToBack(self.titleImageView)

        nowButton.backgroundColor = Palette.goldColor
        otherDayButton.backgroundColor = unselectedBackgroundColor
        optionalTopConstraint.priority = UILayoutPriority(1000)
        optionalBottomConstraint.priority = UILayoutPriority(1000)
        requiredTopConstraint.priority = UILayoutPriority(999)
        requiredBottomConstraint.priority = UILayoutPriority(999)
        descriptionView.isHidden = true
        dateView.isHidden = true
        timeView.isHidden = true
        aboutTextView.layer.mask = gradient
        
        aboutTextView.text = localizedWith("services.cleaning.description")
        self.timeFromTextField.inputView = self.timeFromDatePicker
        self.timeFromTextField.inputAccessoryView = self.timeFromToolbar
        self.timeToTextField.inputView = self.timeToDatePicker
        self.timeToTextField.inputAccessoryView = self.timeToToolbar

		self.closeButton.make(.top, .equal, to: self.safeAreaLayoutGuide, +10)
    }

    func setDelegate(delegate: CleaningViewDelegate) {
        self.delegate = delegate
    }

    func setChoosenDate(date: String) {
        self.dateLabel.text = date
    }

    func setStartTime(time: String) {
        self.timeFromTextField.text = time
    }

    func setEndTime(time: String) {
        self.timeToTextField.text = time
    }

    func setMinimumDate(time: String, isStart: Bool) {
        if isStart {
            self.timeFromDatePicker.updateMinTime(time: time)
            self.timeFromTextField.text = time
        } else {
            self.timeToDatePicker.updateMinTime(time: time)
            self.timeToTextField.text = time
        }
    }
    
    // swiftlint:disable force_unwrapping
    func setChoosenCleaningType(choosenType: Int) {
        self.choosenType = CleaningType(rawValue: choosenType)!
        switch self.choosenType {
        case .springСleaning:
            self.serviceNameLabel.localizedKey = "cleaning.serviceType.springСleaning"
            self.descriptionView.isHidden = true
            optionalTopConstraint.priority = UILayoutPriority(1000)
            requiredTopConstraint.priority = UILayoutPriority(999)
        case .cleaningAfterRenovation:
            self.serviceNameLabel.localizedKey = "cleaning.serviceType.cleaningAfterRenovation"
            self.descriptionView.isHidden = true
            optionalTopConstraint.priority = UILayoutPriority(1000)
            requiredTopConstraint.priority = UILayoutPriority(999)
        case .maintenanceCleaning:
            self.serviceNameLabel.localizedKey = "cleaning.serviceType.maintenanceCleaning"
            self.descriptionView.isHidden = true
            optionalTopConstraint.priority = UILayoutPriority(1000)
            requiredTopConstraint.priority = UILayoutPriority(999)
        case .windowCleaning:
            self.serviceNameLabel.localizedKey = "cleaning.serviceType.windowCleaning"
            self.descriptionView.isHidden = true
            optionalTopConstraint.priority = UILayoutPriority(1000)
            requiredTopConstraint.priority = UILayoutPriority(999)
        case .other:
            self.serviceNameLabel.localizedKey = "cleaning.serviceType.cleaningOther"
            self.descriptionView.isHidden = false
            optionalTopConstraint.priority = UILayoutPriority(999)
            requiredTopConstraint.priority = UILayoutPriority(1000)
        }
    }

    // MARK: - Action

    @IBAction private func serviceDateNow(_ sender: Any) {
        self.delegate?.setNowDate(isNow: true)
        nowButton.backgroundColor = Palette.goldColor
        otherDayButton.backgroundColor = unselectedBackgroundColor
        dateView.isHidden = true
        timeView.isHidden = true
        optionalBottomConstraint.priority = UILayoutPriority(1000)
        requiredBottomConstraint.priority = UILayoutPriority(999)
    }

    @IBAction private func serviceDayOther(_ sender: Any) {
        self.delegate?.setNowDate(isNow: false)
        nowButton.backgroundColor = unselectedBackgroundColor
        otherDayButton.backgroundColor = Palette.goldColor
        dateView.isHidden = false
        timeView.isHidden = false
        optionalBottomConstraint.priority = UILayoutPriority(999)
        requiredBottomConstraint.priority = UILayoutPriority(1000)
    }

    @IBAction private func close(_ sender: Any) {
        self.delegate?.closeController()
    }

    @IBAction private func order(_ sender: Any) {
        if let orderButton = sender as? LocalizableButton {
            orderButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
        }
        self.delegate?.order(text: self.enterDescriptionTextField.text)
    }

    @IBAction private func chooseServiceType(_ sender: Any) {
        self.delegate?.presentParameters()
    }

    @IBAction private func chooseServiceDate(_ sender: Any) {
        self.delegate?.openCalendar()
    }

    /*@IBAction private func openDesriptionText(_ sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            lastPointY = sender.location(in: self).y
            gradient.removeFromSuperlayer()
        } else if sender.state == UIGestureRecognizer.State.changed {
            let yCoordinate = sender.location(in: self).y
            if yCoordinate > lastPointY && textViewHeightConstraint.constant < textViewHeight {
                textViewHeightConstraint.constant += (yCoordinate - lastPointY)
            } else if yCoordinate < lastPointY && textViewHeightConstraint.constant > compressedTextViewHeight {
                textViewHeightConstraint.constant += (yCoordinate - lastPointY)
            }
            if textViewHeightConstraint.constant > textViewHeight {
                textViewHeightConstraint.constant = textViewHeight
            }
            if textViewHeightConstraint.constant < compressedTextViewHeight {
                textViewHeightConstraint.constant = compressedTextViewHeight
                aboutTextView.layer.mask = gradient
            }
            lastPointY = sender.location(in: self).y
        } else if sender.state == UIGestureRecognizer.State.ended {
            lastPointY = sender.location(in: self).y
        }
    }*/

    @IBAction private func openDesriptionText(_ sender: UITapGestureRecognizer) {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.15) {
            if self.textIsFull {
                self.textViewHeightConstraint.constant = self.compressedTextViewHeight
                self.aboutTextView.layer.mask = self.gradient
                self.showTextImageView.isHighlighted = false
                self.textIsFull = false
            } else {
                self.textViewHeightConstraint.constant = self.textViewHeight
                self.gradient.removeFromSuperlayer()
                self.showTextImageView.isHighlighted = true
                self.textIsFull = true
            }
            self.layoutIfNeeded()
        }
    }
    
    @objc
    private func onEndSelectButtonTap() {
        self.delegate?.setTime(time: self.timeToDatePicker.date, isStart: false)
        self.endEditing(true)
    }
    
    @objc
    private func onStartSelectButtonTap() {
        self.delegate?.setTime(time: self.timeFromDatePicker.date, isStart: true)
        self.endEditing(true)
    }

	override func layoutSubviews() {
		super.layoutSubviews()

		self.titleImageGradient.frame = self.titleImageView.bounds
	}
}
