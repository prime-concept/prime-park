import UIKit

final class CountryCodesViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localization.localize("countrycode.title")
        label.textColor = .white
        label.font = UIFont.primeParkFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x606060).withAlphaComponent(0.4)
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 47.5)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.backgroundColor = .clear

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(cellClass: CountryCodeCollectionViewCell.self)
        return collectionView
    }()

    private var data: [CountryCode] = []
    
    private func setupData() {
        data = CountryCode.makeCodes()
        let index = data.firstIndex {
            $0.flagImageName == selectedCountryCode.flagImageName
        }
        guard let validIndex = index else { return }
        data[validIndex].isSelected = true
        let path = IndexPath(row: validIndex, section: 0)
        self.collectionView.selectItem(at: path, animated: true, scrollPosition: .centeredVertically)
        self.collectionView(self.collectionView, didSelectItemAt: path)
    }
    
    private func selectAt(row: Int) {
        for index in data.indices {
            data[index].isSelected = false
        }
        data[row].isSelected = true
    }

    private var selectedCountryCode: CountryCode
    private weak var delegate: CountryCodeSelectionDelegate?

    var scrollView: UIScrollView? {
        self.collectionView
    }

    init(countryCode: CountryCode, delegate: CountryCodeSelectionDelegate?) {
        self.selectedCountryCode = countryCode
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()

        view.backgroundColor = Palette.darkColor

        [self.titleLabel, self.lineView, self.collectionView].forEach(view.addSubview)

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }

        self.lineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(14)
            make.height.equalTo(0.5)
        }

        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.lineView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
    }
}

extension CountryCodesViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        self.data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CountryCodeCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setup(with: self.data[indexPath.row])
        return cell
    }
}

extension CountryCodesViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = self.data[indexPath.row]
        self.selectedCountryCode = item
        selectAt(row: indexPath.row)

        self.delegate?.select(countryCode: item)
    }
}
