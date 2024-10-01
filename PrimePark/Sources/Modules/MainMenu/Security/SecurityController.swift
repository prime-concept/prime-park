import UIKit
import ChatSDK

//swiftlint:disable all
protocol SecurityViewProtocol: ModalRouterSourceProtocol, ChannelModuleOutputProtocol, PushRouterSourceProtocol {
    func closeChat()
}

final class SecurityViewController: PannableViewController {
    private lazy var securityView = SecurityView(
        delegate: self,
        roomNumber: LocalAuthService.shared.apartment?.apartmentNumber ?? ""
    )
    private let presenter: SecurityPresenterProtocol
    private var infoView: InfoView?
    
    init(presenter: SecurityPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        addListener()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = securityView
        self.view.layer.cornerRadius = 20
    }
}

extension SecurityViewController: InfoViewDelegate {
    func onBackButtonTap() {
        self.infoView?.removeFromSuperview()
    }
}

extension SecurityViewController: SecurityViewProtocol {
    func closeChat() {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - ChannelModuleOutputProtocol
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
}

extension SecurityViewController: SecurityViewDelegate {
    func onCallbackButtonTap() {
        self.presenter.callback()
    }

    func onWriteInChatButtonTap() {
        self.presenter.writeInChat()
    }

    func onSecurityCallButtonTap() {
        self.presenter.callToSecurity()
    }

    func onCallSecurityInRoomButtonTap() {
        self.presenter.callSecurityInRoom()
    }

    func onCallSecurityInParkButtonTap() {
        self.presenter.callSecurityInPark()
    }

    func onCallSecurityInLobbyButtonTap() {
        self.presenter.callSecurityInLobby()
    }
}

extension SecurityViewController {
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

    var shouldShowSafeAreaView: Bool { true }
}

extension SecurityViewController {
    @objc
    func changeAccess(notification: Notification) {
        guard let rooms = LocalAuthService.shared.user?.parcingRooms else { return }
        guard let index = notification.userInfo?["roomNumber"] as? Int else { return }
        self.securityView.changeAccess(rooms[index].getRole)
    }
    func addListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeAccess(notification:)), name: .roomChanged, object: nil)
    }
}
