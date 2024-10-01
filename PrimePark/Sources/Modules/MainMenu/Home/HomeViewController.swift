import UIKit
import ChatSDK
import OneSignal
import UserNotifications
import SkeletonView
import MarketPlace

//swiftlint:disable trailing_whitespace
final class HomeViewController: UIViewController {
    
    private lazy var homeView = self.view as? HomeView
    
    private lazy var statusBarView: UIView = {
        let view = UIView()
        view.backgroundColor = Palette.darkColor
        return view
    }()
    
    private let transition = PanelTransition()
    private let logger: PPLogger = PLogger()
    private lazy var bleManager = BLEService.init(logger: logger)
    private let helpChatID = ChatIdType.helpChatID.rawValue
    private let networkService = NetworkService()
    private let offerService = OfferService()
    
    lazy var notificationOpenedBlock: OSNotificationOpenedBlock = { result in
        self.networkService.refreshToken(self.refreshToken, self.username)

        let additionalData = result.notification.rawPayload

        var router = NotificationRouter()
        
        if let id = Self.getChatId(data: additionalData) {
            router.toChat(id: id)
        }
    }
    
    override func loadView() {
        let view = HomeView(delegate: self)
        self.view = view
        self.view.isSkeletonable = true
        self.view.showSkeleton()
        self.view.hideSkeleton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.statusBarView)

        self.statusBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(UIApplication.shared.statusBarFrame.height)
        }
        
        OneSignal.setNotificationOpenedHandler(notificationOpenedBlock)

        NotificationCenter.default.addObserver(self, selector: #selector(self.changeConfiguration), name: .changeBLEConfiguration, object: nil)
        
        RequestService.shared.downloadConfigurations { (configs, token) in
            LocalAuthService.shared.initialUpdate(configs: configs, accessToken: token)
            self.bleManager.updateConfig(config: self.currentBLEConfig)
        }
        
        addListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        homeView?.collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @objc
    private func changeConfiguration() {
        bleManager.updateConfig(config: self.currentBLEConfig)
    }
}

extension HomeViewController: HomeViewDelegate {
    func didTap(item: HomeItemType) {
        switch item {
        case .pass:
            PushRouter(source: self, destination: PassListAssembly(authService: LocalAuthService.shared).make()).route()
        case .parking:
            PushRouter(source: self, destination: ParkingListAssembly(authService: LocalAuthService.shared).make()).route()
        case .news:
            PushRouter(source: self, destination: NewsListAssembly().make()).route()
        case .security:
            let assembly = SecurityAssembly()
            let controller = assembly.make()
            controller.transitioningDelegate = transition
            let router = ModalRouter(source: self, destination: controller, modalPresentationStyle: .custom)
            router.route()
        case .drycleaning:
            ModalRouter(source: self, destination: DryCleaningAssembly(authService: LocalAuthService.shared).make()).route()
        case .cleaning:
			ModalRouter(source: self, destination: CleaningAssembly(authService: LocalAuthService.shared).make()).route()
        case .carwash:
            if offerService.shouldShowOffer {
                let assembly = offerService.showOnboarding {
                    PushRouter(source: self, destination: CarWashAssembly(authService: LocalAuthService.shared).make()).route()
                }
                ModalRouter(source: self, destination: assembly.make()).route()
            } else {
                PushRouter(source: self, destination: CarWashAssembly(authService: LocalAuthService.shared).make()).route()
            }
        case .help:
            checkForNotClosed { issues in
                guard let clearIssues = issues else { return }
                let issue = clearIssues.first { $0.type.id == self.helpChatID && $0.status != .closed }
                if let clearIssue = issue {
                    self.openChat(with: clearIssue.id)
                } else {
                    self.createIssueForChat(with: ChatIdType.helpChatID.rawValue, title: .help)
                }
            }
        case .services:
            PushRouter(source: self, destination: ServiceListAssembly().make()).route()
        case .charges:
            //ModalRouter(source: self, destination: BlockerController(title: "Внимание!", subtitle: "Этот раздел временно недоступен")).route()
            //return
            #warning("change back to ChargesAssembly")
            let controller = ChargesAssembly().make()
            //controller.hidesBottomBarWhenPushed = true
            PushRouter(source: self, destination: controller).route()
        case .market:
            openMarketPlace()
        default:
            let assembly = InfoAssembly(title: Localization.localize("error.newSection.title"), subtitle: Localization.localize("error.newSection.subtitle"), delegate: nil)
            let router = ModalRouter(source: self, destination: assembly.make())
            router.route()
        }
    }
}

extension HomeViewController: ChannelModuleOutputProtocol {
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
        self/*.chatController?*/.present(controller, animated: true, completion: completion)
    }
    //Later
    func didTextViewEditingStatusUpdate(with value: Bool) {
    }
    func didMessageSendingStatusUpdate(with status: ChannelMessageSendingStatus, uid: String) {
    }
    func didChannelControllerStatusUpdate(with status: ChannelControllerStatus) {
    }
    func didChannelAttachementsUpdate(_ update: ChannelAttachmentsUpdate, totalCount: Int) {
    }
    func didChannelVoiceMessageStatusUpdate(with status: ChannelVoiceMessageStatus) {
    }

    var shouldShowSafeAreaView: Bool { false }
}

extension HomeViewController: SingleChatInteractionProtocol {
    internal func openChat(with id: String) {
        let authService = LocalAuthService.shared
        guard let username = authService.user?.username, !username.isEmpty,
            let token = authService.token?.accessToken, !token.isEmpty
        else { return }
        let chatController = ChatAssembly(
            chatToken: token,
            channelID: "PPI\(id)",
            channelName: Localization.localize("home.item.help"),
            clientID: "C\(username)",
            item: nil,
            sourceViewController: self
        ).make()
        PushRouter(source: self, destination: chatController).route()
    }
    
    func openMarketPlace() {
        let user = LocalAuthService.shared.user
        let room = LocalAuthService.shared.room
        let token = LocalAuthService.shared.token
        
        let profile = MarketPlaceProfileModel(token: token?.accessToken,
                                name: user?.shortFullName,
                                address: room?.address,
                                corpus: room?.house,
                                sector: room?.buildingName,
                                floor: room?.floor,
                                apartment: currentApartment?.apartmentNumber,
                                phone: "+\(userPhone?.addPhoneMaskForProfile() ?? "")",
                                email: user?.email,
                                city: "",
                                street: room?.street,
                                entrance: room?.entrance)
            
        let rootViewController = DefaultMarketListFactory.makeMarketList(profile: profile)
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.modalPresentationStyle = .fullScreen
        self.present(module: navController)
    }
    
    func createIssueForChat(with type: String, title: HomeItemType) {
        guard let type = IssuesTypeService.shared.getType(at: type),
              let room = self.currentApartment,
              let token = self.accessToken
        else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.issueEndpoint.createIssue(
                    room: room.id,
                    text: localizedWith(title.title),
                    type: type,
                    token: accessToken
                )
            },
            doneCompletion: { issueData in
                self.openChat(with: issueData.id)
            },
            errorCompletion: { error in
                print("ERROR WHILE CREATE SECURITY CHAT ISSUE: \(error.localizedDescription)")
            }
        )
    }
    internal func checkForNotClosed(completionHandler: @escaping ([Issue]?) -> Void) {
        guard let token = self.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.issueEndpoint.getIssuesList(token: accessToken)
            },
            doneCompletion: { list in
                completionHandler(list)
            },
            errorCompletion: { error in
                completionHandler(nil)
                print("ERROR WHILE DOWNLOAD MY ISSUES LIST: \(error.localizedDescription)")
            }
        )
    }
}

extension HomeViewController: InfoAlertProtocol {}

extension HomeViewController {
    @objc
    func changeAccess(notification: Notification) {
        guard let rooms = LocalAuthService.shared.user?.parcingRooms else { return }
        guard let index = notification.userInfo?["roomNumber"] as? Int else { return }
        self.homeView?.changeAccess(rooms[index].getRole)
    }
    
    func addListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeAccess(notification:)), name: .roomChanged, object: nil)
    }
}

extension HomeViewController {
    private func sendNotification() {
        let endpoint = NotificationsDemoEndpoint()
        guard let token = self.accessToken else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                endpoint.testNotify(token: accessToken)
            },
            doneCompletion: { _ in
                print("done")
            },
            errorCompletion: { error in
                print(error.localizedDescription)
            }
        )
    }
}

fileprivate extension HomeViewController {
    class func getChatId(data: [AnyHashable: Any]) -> String? {
        guard
            let custom = data[AnyHashable("custom")] as? NSDictionary,
            let content = custom["a"] as? NSDictionary,
            let url = content["url"] as? String
            else {
                // handle any error here
                return nil
            }
        return url
            .replacingOccurrences(of: "prpark://chat/", with: "")
            .replacingOccurrences(of: "/", with: "")
    }
}

protocol UserDataHelpProvider {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var currentBLEConfig: BLEConfig? { get }
    var username: String? { get }
    var userPhone: String? { get }
    var currentApartment: Room? { get }
}

extension UserDataHelpProvider {
    var accessToken: String? {
        return LocalAuthService.shared.token?.accessToken
    }
    var refreshToken: String? {
        return LocalAuthService.shared.token?.refreshToken
    }
    var currentBLEConfig: BLEConfig? {
        return LocalAuthService.shared.bleConfiguration
    }
    var username: String? {
        return LocalAuthService.shared.user?.username
    }
    var userPhone: String? {
        return LocalAuthService.shared.user?.phone
    }
    var currentApartment: Room? {
        return LocalAuthService.shared.apartment
    }
}


extension HomeViewController: UserDataHelpProvider {}
