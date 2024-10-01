import UIKit

protocol PassForMeListControllerProtocol: class, ModalRouterSourceProtocol, PushRouterSourceProtocol {
    func setActive(issues: [IssuePass])
    func setHistory(issues: [IssuePass])
    func stopRefreshing()
}

final class PassForMeListController: UIViewController {
    private lazy var passListView: PassForMeListView = {
        var view = Bundle.main.loadNibNamed("PassForMeListView", owner: nil, options: nil)?.first as? PassForMeListView ?? PassForMeListView()
        return view
    }()
    
    private lazy var blurView: UIView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.passListView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()

    private let presenter: PassForMeListPresenterProtocol
    private var infoView: InfoView?
    private var activePasses: [IssuePass] = []
    private var historyPasses: [IssuePass] = []
    private var isIGive: Bool = true

    init(presenter: PassForMeListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.passListView
        self.passListView.addDelegate(self)
        passListView.commonInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        presenter.getStartIssues()
    }
}

extension PassForMeListController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension PassForMeListController: PassForMeListViewDelegate {
    
    func updatePasses(currentCount: Int, isActive: Bool) {
        presenter.updatePasses(count: currentCount, isActive: isActive)
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PassForMeListController: PassForMeListControllerProtocol {
    
    func setActive(issues: [IssuePass]) {
        activePasses += issues
        passListView.setActive(issues: activePasses)
    }
    
    func setHistory(issues: [IssuePass]) {
        historyPasses += issues
        passListView.setHistory(issues: historyPasses)
    }
    
    func stopRefreshing() {
        passListView.stopRefreshing()
    }
}
