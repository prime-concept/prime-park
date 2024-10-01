import UIKit

protocol CarWashViewDelegate: class {
    func closeController()
    func presentServices()
    func presentKeyTransferTypes()
    func openHistoryRecord(index: Int)
    func openCalendar()
    func openMoreInfo()
    func makeOrder()
}

private enum CarWashType: Int {
    case washingOutside
    case engineWash
    case complexWashing
    case motorcycleWash
    case other
}

private enum CarDriver: Int {
    case personally
    case valet
    case belboy
}

final class CarWashView: UIView {
    private weak var delegate: CarWashViewDelegate?
    private var historyRecords: [HistoryRecordViewModel] = []
    
    
    private var lastPointY: CGFloat = 0
    private let compressedTextViewHeight: CGFloat = 81.0
    private var textIsFull = false
    @IBOutlet weak var keytransferType: LocalizableLabel!
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

	@IBOutlet weak var titleImageView: UIImageView!
	@IBOutlet private weak var aboutTextView: UITextView!
    @IBOutlet private weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var showTextImageView: UIImageView!
    @IBOutlet private weak var order: LocalizableButton!
    
    @IBOutlet weak var serviceLabel: LocalizableLabel!
    
    @IBOutlet weak var dateLabel: LocalizableLabel!
    @IBOutlet weak var segmentControl: PrimeSegmentControl!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    init(delegate: CarWashViewDelegate?) {
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
        self.aboutTextView.layer.mask = gradient
        self.aboutTextView.text = localizedWith("carWash.about.text")
        self.segmentControl.delegate = self
        self.historyView.isHidden = true
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        self.historyTableView.register(
            CarWashHistorTableViewCell.self,
            forCellReuseIdentifier: CarWashHistorTableViewCell.defaultReuseIdentifier
        )
        self.historyTableView.reloadData()
    }

    func setDelegate(delegate: CarWashViewDelegate) {
        self.delegate = delegate
    }

    func setChoosenKeyTransferType(type: String) {
        self.keytransferType.text = type
    }

    func setRecordsHistory(history: [HistoryRecordViewModel]) {
        self.historyRecords = history
        self.historyTableView.reloadData()
    }

    func openDetailRecord(index: Int) {
        self.delegate?.openHistoryRecord(index: index)
    }

    func setServiceType(type: String) {
        self.serviceLabel.text = type
    }

    func setDateLabel(date: String) {
        self.dateLabel.text = date
    }
    // MARK: - Action

    
    @IBAction func openMoreInfo(_ sender: Any) {
        self.delegate?.openMoreInfo()
    }
    @IBAction func openDescriptionText(_ sender: Any) {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
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
    
    @IBAction func chooseDateAndTime(_ sender: Any) {
        self.delegate?.openCalendar()
    }
    
    @IBAction func chooseServiceType(_ sender: Any) {
        self.delegate?.presentServices()
    }

    @IBAction func chooseKeyTransfer(_ sender: Any) {
        self.delegate?.presentKeyTransferTypes()
    }

    @IBAction private func close(_ sender: Any) {
        self.delegate?.closeController()
    }

    @IBAction func makeOrder(_ sender: Any) {
        self.delegate?.makeOrder()
    }
}

extension CarWashView {
    func call(_ companyPhone: String) {
        if let phone = URL(string: "tel://\(companyPhone)"),
            UIApplication.shared.canOpenURL(phone) {
            UIApplication.shared.open(phone)
        }
    }
}

extension CarWashView: PrimeSegmentControlDelegate {
    func didChange(index: Int) {
        self.historyView.isHidden = index == 0
    }
}

extension CarWashView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CarWashHistorTableViewCell.defaultReuseIdentifier,
            for: indexPath
        ) as? CarWashHistorTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(with: historyRecords[indexPath.row])
        cell.addTapHandler { [weak self] in
            self?.openDetailRecord(index: indexPath.row)
        }
        return cell
    }
    
    
}

