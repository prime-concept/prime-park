import UIKit
import SkeletonView
//swiftlint:disable all
protocol PassForMeListViewDelegate: class {
    func back()
    func updatePasses(currentCount: Int, isActive: Bool)
}

final class PassForMeListView: UIView {
    @IBOutlet private weak var segmentControl: PrimeSegmentControl!
    @IBOutlet weak var activeTableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    
    var currentTableView: UITableView {
        return segmentControl.selectedSegmentIndex == 0 ? activeTableView : historyTableView
    }

    private weak var passDelegate: PassForMeListViewDelegate?
    
    private var activePasses: [IssuePass] = [] {
        didSet {
//            guard !activePasses.isEmpty else { return }
            activeTableView.reloadData()
            activeTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.3))
        }
    }
    private var historyPasses: [IssuePass] = [] {
        didSet {
//            guard !historyPasses.isEmpty else { return }
            historyTableView.reloadData()
            historyTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.3))
        }
    }
    
    private var refreshControl = UIRefreshControl()
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
        activeTableView.registerNib(cellClass: PassForMeCell.self)
        historyTableView.registerNib(cellClass: PassForMeCell.self)
        
        activeTableView.dataSource = self
        activeTableView.delegate = self
        
        historyTableView.dataSource = self
        historyTableView.delegate = self
        
        var insets = activeTableView.contentInset
        insets.bottom += 60
        activeTableView.contentInset = insets
        historyTableView.contentInset = insets
        
        [activeTableView, historyTableView].forEach {
            $0?.rowHeight = 48
            $0?.estimatedRowHeight = 48
        }
        
        isLoaded = false
        
        segmentControl.delegate = self
        
        makeSkeletonable()
    }

    func addDelegate(_ delegate: PassForMeListViewDelegate) {
        self.passDelegate = delegate
    }
    
    func setActive(issues: [IssuePass]) {
        activePasses = issues
        isLoaded = true
    }
    
    func setHistory(issues: [IssuePass]) {
        historyPasses = issues
        isLoaded = true
    }
    
    func stopRefreshing() {
        isLoaded = true
        removeFooterSpiner(tableView: currentTableView)
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
}

extension PassForMeListView: SkeletonTableViewDataSource, SkeletonTableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === activeTableView {
            return activePasses.count
        } else {
            return historyPasses.count
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PassForMeCell.defaultReuseIdentifier
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        
        let cell: PassForMeCell = tableView.dequeueReusableCell(for: indexPath)
        
        let array = tableView === activeTableView ? activePasses : historyPasses
        
        if !array.isEmpty {
            cell.setData(pass: array[indexPath.row])
        }
        
        return cell
    }
}


extension PassForMeListView: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottom = scrollView.contentOffset.y + scrollView.frame.height
        if bottom > scrollView.contentSize.height && isIssuesUpdatingDone {
            isIssuesUpdatingDone = false
            createFooterSpiner(tableView: scrollView as! UITableView)
            passDelegate?.updatePasses(
                currentCount: segmentControl.selectedSegmentIndex == 0 ?
                    activePasses.count :
                    historyPasses.count,
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

extension PassForMeListView {
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

extension PassForMeListView {
    func makeSkeletonable() {
        [activeTableView, historyTableView].forEach {
            $0?.isSkeletonable = true
            $0?.showAnimatedGradientSkeleton(
                usingGradient: .init(baseColor: UIColor(hex: 0x353535),
                                secondaryColor: UIColor(hex: 0x212121)),
                animation: nil,
                transition: .crossDissolve(0.25)
            )
        }
    }
}

extension PassForMeListView: PrimeSegmentControlDelegate {
    func didChange(index: Int) {
        let isActive = index == 0 ? true : false
        activeTableView.isHidden = !isActive
        historyTableView.isHidden = isActive
    }
}
