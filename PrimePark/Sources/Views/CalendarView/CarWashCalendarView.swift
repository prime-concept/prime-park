import Foundation
import SnapKit

protocol CarWashCalendarViewDelegate: AnyObject {
    func setChoosenDateAndTime()
    func updateDate(index: Int)
    func updateTime(index: Int)
}

final class CarWashCalendarView: UIView {

    weak var delegate: CarWashCalendarViewDelegate?
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldPrimeParkFont(ofSize: 16)
        label.text = localizedWith("carWash.dateAndTime.title")
        label.textColor = .white
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 12)
        label.text = localizedWith("carWash.chooseDateAndTime")
        label.textColor = .white
        return label
    }()

    private lazy var emptyTimeslotLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.primeParkFont(ofSize: 12)
        label.textAlignment = .center
        label.text = localizedWith("carWash.empty.timeslots")
        label.textColor = Palette.darkLightColor
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()

    private lazy var bottomSeparatorView: UIView = {
        let view = OnePixelHeightView()
        view.backgroundColor = .gray
        view.alpha = 0.2
        return view
    }()
    
    private lazy var chooseButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Palette.mainColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle(localizedWith("carWash.choose"), for: .normal)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(self.onChooseButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 3
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(cellClass: CalendarDayItemCollectionViewCell.self)

        return collectionView
    }()
    
    private lazy var timeSlotCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(cellClass: TimeslotCollectionViewCell.self)

        return collectionView
    }()

    private lazy var dates = [DaysModel]()
    private lazy var timeslots = [TimeslotModel]()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = UIColor(hex: 0x313131)
    }
    
    func addSubviews() {
        [
            self.titleLabel,
            self.subtitleLabel,
            self.separatorView,
            self.calendarCollectionView,
            self.bottomSeparatorView,
            self.timeSlotCollectionView,
            self.emptyTimeslotLabel,
            self.chooseButton
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
        }
        self.calendarCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.separatorView.snp.bottom).offset(15)
            make.height.equalTo(67)
        }
        self.bottomSeparatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.calendarCollectionView.snp.bottom).offset(15)
        }
        self.timeSlotCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.bottomSeparatorView.snp.bottom).offset(15)
            make.height.equalTo(25)
        }
        self.emptyTimeslotLabel.snp.makeConstraints { make in
            make.top.equalTo(self.bottomSeparatorView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(17)
        }
        self.chooseButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(self.timeSlotCollectionView.snp.bottom).offset(30)
            make.height.equalTo(45)
        }
    }

    func updateDates(dates: [DaysModel]) {
        self.dates = dates
        self.calendarCollectionView.reloadData()
    }

    func updateTimeslots(timeslots: [TimeslotModel]) {
        if timeslots.isEmpty {
            self.emptyTimeslotLabel.isHidden = false
            self.chooseButton.alpha = 0.5
            self.chooseButton.isEnabled = false
        } else {
            self.emptyTimeslotLabel.isHidden = true
            self.chooseButton.alpha = 1
            self.chooseButton.isEnabled = true
        }
        self.timeslots = timeslots
        self.timeSlotCollectionView.reloadData()
    }

    private func didTapDate(on indexPath: IndexPath) {
        self.delegate?.updateDate(index: indexPath.row)
    }

    private func didTapTime(on indexPath: IndexPath) {
        self.delegate?.updateTime(index: indexPath.row)
    }

    @objc
    private func onChooseButtonTap() {
        self.delegate?.setChoosenDateAndTime()
    }
}

extension CarWashCalendarView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.calendarCollectionView {
            return self.dates.count
        }
        return self.timeslots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.calendarCollectionView {
            let cell: CalendarDayItemCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setup(with: dates[indexPath.row])
            cell.addTapHandler { [weak self] in
                self?.didTapDate(on: indexPath)
            }
            return cell
        }
        let cell: TimeslotCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setup(with: self.timeslots[indexPath.row])
        cell.addTapHandler { [weak self] in
            self?.didTapTime(on: indexPath)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == self.calendarCollectionView {
            return CGSize(width: 44, height: 65)
        }
        return CGSize(width: 52, height: 24)
    }
}
