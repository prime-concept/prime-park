import UIKit

//swiftlint:disable all
protocol ConciergeListViewDelegate: class {
    func updateIssues(currentCount: Int)
    func didChooseItem(index: Int, isWork: Bool)
    func newRequest()
}

final class ConciergeListView: UIView {
    @IBOutlet weak var inWorkTable: UITableView!
    @IBOutlet weak var doneTable: UITableView!
    
    @IBOutlet weak var segmentedControl: PrimeSegmentControl!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var requestButton: LocalizableButton!
    
    private weak var conciergeListViewDelegate: ConciergeListViewDelegate?
    
    private var channels: [Channel] = []
    
    var inWorkItems: [Issue] = Array(repeating: Issue(), count: 10) {
        didSet {
            isContentLoaded = true
            isIssuesUpdatingDone = true
            inWorkTable.reloadData()
            requestButton.endButtonLoadingAnimation(defaultTitle: localizedWith("concierge.newRequestButton.title"))
            inWorkTable.stopSolidAnimation()
        }
    }
    
    var doneItems: [Issue] = Array(repeating: Issue(), count: 10) {
        didSet {
            isContentLoaded = true
            isIssuesUpdatingDone = true
            requestButton.endButtonLoadingAnimation(defaultTitle: localizedWith("concierge.newRequestButton.title"))
            doneTable.reloadData()
            doneTable.stopSolidAnimation()
        }
    }
    
    var previews = (workPreview: false, completePreview: false) {
        didSet {
            setEmptyPreviewIfNeeded()
        }
    }
    
    private var isWork = true
    
    var isContentLoaded = false
    var isIssuesUpdatingDone = true
    

    init(delegate: ConciergeListViewDelegate?) {
        self.conciergeListViewDelegate = delegate
        super.init(frame: .zero)
    }

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: - Public API

    func commonInit() {
        // inWorkTable setup
        inWorkTable.registerNib(cellClass: ConciergeTableViewCell.self)
        self.inWorkTable.dataSource = self
        self.inWorkTable.delegate = self
        var insets = inWorkTable.contentInset
        insets.bottom += 60
        inWorkTable.contentInset = insets

        // doneTable setup
        doneTable.registerNib(cellClass: ConciergeCloseTableViewCell.self)
        self.doneTable.dataSource = self
        self.doneTable.delegate = self
        doneTable.contentInset = insets
        
        segmentedControl.delegate = self
    }

    func setDelegate(delegate: ConciergeListViewDelegate) {
        self.conciergeListViewDelegate = delegate
    }
    
    func setChannel(channel: Channel) {
        inWorkItems = channel.integrateWithIssues(issues: inWorkItems)
        doneItems = channel.integrateWithIssues(issues: doneItems)
        self.channels = channel.content
    }

    // MARK: - Action

    @IBAction private func createNewRequest(_ sender: Any) {
        conciergeListViewDelegate?.newRequest()
    }
    
    func setEmptyPreviewIfNeeded() {
        if previews.workPreview {
            noDataView.isHidden = !isWork
        } else if previews.completePreview {
            noDataView.isHidden = isWork
        }
    }
}

extension ConciergeListView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = tableView === inWorkTable ? inWorkItems.count : doneItems.count
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === inWorkTable {
            let cell: ConciergeTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.contentBackgroundView.backgroundColor = Palette.backgroundCell
            guard inWorkItems.count > 0 else { return cell }
            cell.setData(item: inWorkItems[indexPath.row])
            return cell
        } else {
            let cell: ConciergeCloseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.contentBackgroundView.backgroundColor = Palette.backgroundCell
            guard doneItems.count > 0 else { return cell }
            cell.setData(item: doneItems[indexPath.row])
            return cell
        }
    }
}

extension ConciergeListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.conciergeListViewDelegate?.didChooseItem(index: indexPath.row, isWork: isWork)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottom = scrollView.contentOffset.y + scrollView.frame.height
        if bottom > scrollView.contentSize.height && isIssuesUpdatingDone && isContentLoaded {
            isIssuesUpdatingDone = false
            createFooterSpiner()
            conciergeListViewDelegate?.updateIssues(
                currentCount: segmentedControl.selectedSegmentIndex == 0 ? inWorkItems.count : doneItems.count
            )
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isIssuesUpdatingDone {
            removeFooterSpiner()
        }
    }
}

extension ConciergeListView {
    func createFooterSpiner() {
        let back = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let loading = UIActivityIndicatorView(style: .white)
        loading.center = back.center
        back.addSubview(loading)
        loading.startAnimating()
        [inWorkTable, doneTable].forEach { $0.tableFooterView = back }
    }
    func removeFooterSpiner() {
        [inWorkTable, doneTable].forEach { $0.tableFooterView = nil }
    }
}

extension ConciergeListView: PrimeSegmentControlDelegate {
    func didChange(index: Int) {
        self.isWork = index == 0
        
        setEmptyPreviewIfNeeded()
        
        inWorkTable.isHidden = !isWork
        doneTable.isHidden = isWork
    }
}
