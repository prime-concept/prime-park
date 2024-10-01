import UIKit
import ChatSDK
//swiftlint:disable all
protocol ConciergeListControllerProtocol: class, ModalRouterSourceProtocol, ChannelModuleOutputProtocol, PushRouterSourceProtocol, LoadableWithButton {
    func setMyRequests(list: [Issue], isInWork: Bool)
    func updateIssuesIndicators(channel: Channel)
    func appearTabBarUnreadIndicator(value: Int?)
}

final class ConciergeListController: UIViewController {
    private lazy var conciergeListView: ConciergeListView = {
        var view = Bundle.main.loadNibNamed("ConciergeListView", owner: nil, options: nil)?.first as? ConciergeListView ?? ConciergeListView(delegate: self)
        return view
    }()

    var requestButton: LocalizableButton! {
        get {
            conciergeListView.requestButton
        }
    }
    private let presenter: ConciergeListPresenterProtocol
    private var infoView: InfoView?
    private var isStartTimePicker: Bool = true
    private var inWorkArray: [Issue] = []
    private var doneArray: [Issue] = []
    private var isInWork: Bool = true
    private let companyPhone = "+74954812244"
    //private var itemsArray: [Issue] = []
    

    init(presenter: ConciergeListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been i as! ChannelModuleOutputProtocolmplemented")
    }

    override func loadView() {
        self.view = self.conciergeListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        conciergeListView.commonInit()
        self.conciergeListView.setDelegate(delegate: self)
        
        let callButton = UIBarButtonItem(
            image: UIImage(named: "call_concierge")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(callConcierge)
        )
        navigationItem.rightBarButtonItem = callButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestIssues()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
        
        [conciergeListView.inWorkTable, conciergeListView.doneTable].forEach { $0?.startSolidAnimation() }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        doneArray = []
        inWorkArray = []
        conciergeListView.isContentLoaded = false
        conciergeListView.noDataView.isHidden = true
        conciergeListView.inWorkItems = Array(repeating: Issue(), count: 10)
        conciergeListView.doneItems = Array(repeating: Issue(), count: 10)
        conciergeListView.previews = (false, false)
    }

    @objc
    private func callConcierge() {
        if let phone = URL(string: "tel://\(companyPhone)"),
            UIApplication.shared.canOpenURL(phone) {
            UIApplication.shared.open(phone)
        }
    }
}

extension ConciergeListController {
    func requestIssues() {
		if Config.isDebugEnabled {
			self.presenter.requestStartIssues()
		} else {
			self.presenter.updateChannels(withRequests: true)
		}
    }
    
    // MARK: - Updating tabbar badge indicator
    
    func appearTabBarUnreadIndicator(value: Int?) {
        guard let clearValue = value else { return }
        if let tabBarItem = self.tabBarController?.tabBar {
            if clearValue == 0 {
                tabBarItem.items?[1].badgeValue = nil
            } else {
                tabBarItem.items?[1].badgeValue = "\(clearValue)"
            }
        }
    }
}

extension ConciergeListController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension ConciergeListController: ConciergeListViewDelegate {
    
    func updateIssues(currentCount: Int) {
        presenter.getMyRequests(
            isInWork: conciergeListView.segmentedControl.selectedSegmentIndex == 0,
            count: 20,
            offset: currentCount
        )
    }
    
    func didChooseItem(index: Int, isWork: Bool) {
        self.isInWork = isWork
        self.presenter.choosenRequest(item: isWork ? inWorkArray[index] : doneArray[index])
    }
	
    func newRequest() {
        presenter.newRequest()
    }
}

extension ConciergeListController: ConciergeListControllerProtocol {
    
    func setMyRequests(list: [Issue], isInWork: Bool) {
        let sortedList = list//.sorted { $0.date > $1.number }
        if isInWork {
            self.inWorkArray.append(contentsOf: sortedList)
            self.conciergeListView.previews.workPreview = inWorkArray.count == 0
            self.conciergeListView.inWorkItems = self.inWorkArray
        } else {
            self.doneArray.append(contentsOf: sortedList)
            self.conciergeListView.previews.completePreview = doneArray.count == 0
            self.conciergeListView.doneItems = self.doneArray
        }
        
        //self.conciergeListView.previews = (inWorkArray.count == 0, doneArray.count == 0)
    }
    
    func updateIssuesIndicators(channel: Channel) {
        appearTabBarUnreadIndicator(value: channel.allUnreadCount)
        conciergeListView.setChannel(channel: channel)
    }
}

extension ConciergeListController: ChannelModuleOutputProtocol {
    func requestPhoneCall(number: String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    func requestPresentation(for controller: UIViewController, completion: (() -> Void)?) {
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: completion)
    }
    //Later
    func didTextViewEditingStatusUpdate(with value: Bool) {
        print("didTextViewEditingStatusUpdate")
    }
    func didMessageSendingStatusUpdate(with status: ChannelMessageSendingStatus, uid: String) {
        print("didMessageSendingStatusUpdate")
    }
    func didChannelControllerStatusUpdate(with status: ChannelControllerStatus) {
        print("didChannelControllerStatusUpdate")
    }
    func didChannelAttachementsUpdate(_ update: ChannelAttachmentsUpdate, totalCount: Int) {
        print("didChannelAttachementsUpdate")
    }
    func didChannelVoiceMessageStatusUpdate(with status: ChannelVoiceMessageStatus) {
        print("didChannelVoiceMessageStatusUpdate")
    }

    var shouldShowSafeAreaView: Bool { false }
}
