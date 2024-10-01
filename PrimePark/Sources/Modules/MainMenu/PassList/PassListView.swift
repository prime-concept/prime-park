import UIKit
//swiftlint:disable all
protocol PassListViewProtocol: AnyObject {
    func back()
    func updatePasses(isActive: Bool)
    func newPass()
    func showDetail(for pass: IssuePass)
    func showInfo()
}

final class PassListView: UIView {
    @IBOutlet weak var segmentControl: PrimeSegmentControl!
    @IBOutlet weak var activeTableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    
    var currentTableView: UITableView {
        return segmentControl.selectedSegmentIndex == 0 ? activeTableView : historyTableView
    }
    
    @IBOutlet private weak var createPassButton: LocalizableButton!

    private weak var passDelegate: PassListViewProtocol?
    
    private var activePasses: [IssuePass] = Array(repeating: IssuePass(), count: 10) {
        didSet {
            activeTableView.reloadData()
            activeTableView.stopSolidAnimation(isLodable: false)
        }
    }
    private var historyPasses: [IssuePass] = Array(repeating: IssuePass(), count: 10) {
        didSet {
            historyTableView.reloadData()
            historyTableView.stopSolidAnimation(isLodable: false)
        }
    }
    
    var isLoaded: Bool = false {
        didSet {
            isIssuesUpdatingDone = true
        }
    }
    
    // For spiner indicator
    var isIssuesUpdatingDone = true

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

    func commonInit() {
        activeTableView.registerNib(cellClass: PassListIGiveTableViewCell.self)
        historyTableView.registerNib(cellClass: PassListIGiveTableViewCell.self)
        
        activeTableView.dataSource = self
        activeTableView.delegate = self
        activeTableView.isLoadable = true
        
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.isLoadable = true
        
        var insets = activeTableView.contentInset
        insets.bottom += 60
        activeTableView.contentInset = insets
        historyTableView.contentInset = insets
        
        [activeTableView, historyTableView].forEach {
            $0?.rowHeight = 67
            $0?.estimatedRowHeight = 67
        }
        
        segmentControl.delegate = self
        
        isLoaded = false
    }

    func addDelegate(_ delegate: PassListViewProtocol) {
        self.passDelegate = delegate
    }
    
    func setActive(issues: [IssuePass], isChanged: Bool) {
        if !isChanged {
            passDelegate?.updatePasses(isActive: true)
        }
        activePasses = issues
        isLoaded = true
    }
    
    func setHistory(issues: [IssuePass], isChanged: Bool) {
        if !isChanged { passDelegate?.updatePasses(isActive: false); }
        historyPasses = issues
        isLoaded = true
    }
    
    func stopRefreshing() {
        isLoaded = true
        removeFooterSpiner(tableView: currentTableView)
    }

    func setButtonEnabled(_ enabled: Bool) {
        self.createPassButton.isEnabled = enabled
    }

    // MARK: - Private API

    @objc
    private func refresh(_ sender: AnyObject) {
       // Code to refresh table view
    }

    // MARK: - Actions

    @IBAction private func back(_ sender: Any) {
        self.passDelegate?.back()
    }

    @IBAction private func info(_ sender: Any) {
        self.passDelegate?.showInfo()
    }

    @IBAction private func createNewPass(_ sender: Any) {
        self.passDelegate?.newPass()
    }
}

extension PassListView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === activeTableView {
            return activePasses.count
        } else {
            return historyPasses.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        
        let cell: PassListIGiveTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let array = tableView === activeTableView ? activePasses : historyPasses
        
        if !array.isEmpty {
            cell.setData(pass: array[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.startSolidAnimation()
    }
}


extension PassListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let array = tableView === activeTableView ? activePasses : historyPasses
        passDelegate?.showDetail(for: array[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottom = scrollView.contentOffset.y + scrollView.frame.height
        if bottom > scrollView.contentSize.height && isIssuesUpdatingDone {
            isIssuesUpdatingDone = false
            createFooterSpiner(tableView: scrollView as! UITableView)
            passDelegate?.updatePasses(
                isActive: !Bool(segmentControl.selectedSegmentIndex)
            )
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isIssuesUpdatingDone {
            removeFooterSpiner(tableView: scrollView as! UITableView)
        }
    }
}

extension PassListView {
    func createFooterSpiner(tableView: UITableView) {
        let back = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let loading = UIActivityIndicatorView(style: .white)
        loading.center = back.center
        back.addSubview(loading)
        loading.startAnimating()
        tableView.tableFooterView = back
    }
    
    func removeFooterSpiner(tableView: UITableView) {
        tableView.tableFooterView = nil
    }
}


extension PassListView: PrimeSegmentControlDelegate {
    func didChange(index: Int) {
        let isActive = index == 0 ? true : false
        activeTableView.isHidden = !isActive
        historyTableView.isHidden = isActive
    }
}
