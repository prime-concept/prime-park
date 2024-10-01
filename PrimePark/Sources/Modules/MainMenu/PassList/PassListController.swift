import UIKit

protocol PassListControllerProtocol: ModalRouterSourceProtocol, PushRouterSourceProtocol {
    func setActive(issues: [IssuePass], isStart: Bool)
    func setHistory(issues: [IssuePass], isStart: Bool)
    func stopRefreshing()
}

final class PassListController: UIViewController {
    
    private lazy var passListView: PassListView = {
        var view = Bundle.main.loadNibNamed("PassListView", owner: nil, options: nil)?.first as? PassListView ?? PassListView()
        return view
    }()

    private let presenter: PassListPresenterProtocol
    private var infoView: InfoView?
    private var activePasses: [IssuePass] = []
    private var historyPasses: [IssuePass] = []
    private var isIGive: Bool = true
    private var roomId: Int = 0

    init(presenter: PassListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = self.passListView
        self.passListView.addDelegate(self)
        passListView.commonInit()
        self.passListView.setButtonEnabled(self.presenter.canCreatePass())
        guard let room = LocalAuthService.shared.apartment else { return }
        self.roomId = room.id
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.needDeleteCurrentPass), name: .passControllerDidClose, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        presenter.getStartIssues()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        passListView.activeTableView.isLoadable = true
        passListView.historyTableView.isLoadable = true
    }
    

    @objc
    private func needDeleteCurrentPass() {
        presenter.needDeleteCurrentPass()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }
}

extension PassListController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension PassListController: PassListViewProtocol {
    
    func updatePasses(isActive: Bool) {
        presenter.updatePasses(isActive: isActive)
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }

    func newPass() {
        self.presenter.createNewPass()
    }

    func showDetail(for pass: IssuePass) {
        //self.passListView.addSubview(blurView)
        presenter.showDetail(for: pass)
    }

    func showInfo() {
        presenter.showInfo()
    }
}

extension PassListController: PassListControllerProtocol {
    
    func setActive(issues: [IssuePass], isStart: Bool) {
        
        let filtered = issues.filter { $0.room == roomId }
        let isChanged = !(filtered.isEmpty && !issues.isEmpty)
        if isStart {
            activePasses = filtered
        } else {
            activePasses.append(contentsOf: filtered)
        }
        passListView.setActive(issues: activePasses, isChanged: isChanged)
    }
    
    func setHistory(issues: [IssuePass], isStart: Bool) {
        let filtered = issues.filter { $0.room == roomId }
        let isChanged = !(filtered.isEmpty && !issues.isEmpty)
        if isStart {
            historyPasses = filtered
        } else {
            historyPasses.append(contentsOf: filtered)
        }
        passListView.setHistory(issues: historyPasses, isChanged: isChanged)
    }
    
    func stopRefreshing() {
        passListView.stopRefreshing()
    }
}
