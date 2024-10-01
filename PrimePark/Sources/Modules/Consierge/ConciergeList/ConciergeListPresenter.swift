import Foundation

import UIKit
import ChatSDK
import Starscream

//swiftlint:disable all
protocol ConciergeListPresenterProtocol {
    func getMyRequests(isInWork: Bool, count: Int, offset: Int)
    func requestStartIssues()
    func choosenRequest(item: Issue)
    func newRequest()
    func updateChannels(withRequests: Bool)
}

final class ConciergeListPresenter: ConciergeListPresenterProtocol {
	
    private let authService: LocalAuthService
    private var socketService: WSService?
    private var networkService = NetworkService()
    
    private let issuesEndpoint: IssuesEndpoint
    private let channelsEndpoint = ChannelsEndpoint()
	
	private let dispatchGroup = DispatchGroup()
    
    private var channel: Channel?
    private var currentRequest = ConsiergeRequest.types
    private var helpTypeID = ChatIdType.helpChatID.rawValue
    private var securityTypeID = ChatIdType.securityChatID.rawValue
    
    private var lastUpdateTime: TimeInterval = .zero
	
	private lazy var titleView: ChatNavigationTitleView = {
		let view = Bundle.main.loadNibNamed("ChatNavigationTitleView", owner: nil, options: nil)?.first as? ChatNavigationTitleView ?? ChatNavigationTitleView()
		return view
	}()

    weak var controller: ConciergeListControllerProtocol?

    init(endpoint: IssuesEndpoint, authService: LocalAuthService) {
        self.issuesEndpoint = endpoint
        self.authService = authService
        
        lastUpdateTime = Date().timeIntervalSince1970 - 1
        subscribeOnSeenMessageEvent()
        loadIssueTypes()
    }
    
    func newRequest() {
        guard let controller = controller else { return }
        let issueMenu = IssueMenuAssembly(fromVC: controller).make()
        ModalRouter(
            source: controller,
            destination: issueMenu,
            modalPresentationStyle: .overFullScreen
        ).route()
    }

    func choosenRequest(item: Issue) {
        guard
            let username = authService.user?.username, !username.isEmpty,
            let token = authService.token?.accessToken, !token.isEmpty
        else {
            fatalError("User doesn`t exist")
        }

        guard let sourceController = self.controller else {
            return
        }
        
        titleView.setData(item: item)
        
        let chatController = ChatAssembly(
            chatToken: token,
            channelID: "PPI\(item.id)",
            channelName: item.typeDesctiption,
            clientID: "C\(username)",
            item: item,
            sourceViewController: sourceController,
            titleView: titleView
        ).make()
		        PushRouter(source: sourceController, destination: chatController).route()
    }

    // MARK: - Private API
    
    func updateChannels(withRequests: Bool) {
        guard let token = LocalAuthService.shared.token?.accessToken else { return }
        networkService.request(
			accessToken: token,
			requestCompletion: { accessToken in
                self.channelsEndpoint.getChannels(token: accessToken)
            },
            doneCompletion: { channel in
                self.channel = channel
                if withRequests {
                    self.requestStartIssues()
                } else {
                    self.controller?.updateIssuesIndicators(channel: channel)
                }
            },
            errorCompletion: { error in
                print("ERROR WHILE DOWNLOAD CHANNELS LIST: \(error.localizedDescription)")
            }
        )
    }
    
    func requestStartIssues() {
        self.getMyRequests(
            isInWork: true,
            count: 20,
            offset: 0
        )
		
		dispatchGroup.notify(queue: NetworkService.workingQueue) { [weak self] in
			self?.getMyRequests(
				isInWork: false,
				count: 20,
				offset: 0
			)
		}
    }

	func getMyRequests(isInWork: Bool, count: Int, offset: Int) {
		dispatchGroup.enter()
		
        self.currentRequest = .issuesLoad
        guard let token = self.authService.token?.accessToken else { return }
        
		print(token)
		
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.issuesEndpoint.getIssuesList(
                    token: accessToken,
                    status: isInWork ? IssueStatus.inWorkStatuses : IssueStatus.closedStatuses,
                    all: false,
                    count: 20,
                    offset: Int32(offset)
                )
            },
            doneCompletion: { list in
				self.dispatchGroup.leave()
				
                var updatedList = list
                if let channel = self.channel {
                    updatedList = channel.integrateWithIssues(issues: list)
                }
                self.controller?.setMyRequests(list: updatedList, isInWork: isInWork)
                self.controller?.appearTabBarUnreadIndicator(value: self.channel?.allUnreadCount)
            },
            errorCompletion: { error in
                self.dispatchGroup.leave()
                print("ERROR WHILE DOWNLOAD MY ISSUES LIST: \(error.localizedDescription)")
            }
        )
    }

    private func loadIssueTypes() {
        self.currentRequest = ConsiergeRequest.types
        guard let token = self.authService.token?.accessToken else { return }
        //let responseDate = Date()
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.issuesEndpoint.getIssuesTypes(token: accessToken)
            },
            doneCompletion: { list in
                IssuesTypeService.shared.addTypes(list: list)
            },
            errorCompletion: { error in
                print("ERROR WHILE DOWNLOAD ISSUE TYPES LIST: \(error.localizedDescription)")
            }
        )
    }
	
	private enum ConsiergeRequest {
		case types
		case issuesLoad
	}
}

extension ConciergeListPresenter: WebSocketDelegate {
    
    // MARK: - Delegate Methods
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect")
		if Config.isDebugEnabled {
			return
		}

		if let error = error as? WSError,
		   let token = authService.token?.refreshToken,
		   let username = authService.user?.username {
			print(error.localizedDescription)
			switch error.type {
			case .protocolError:
				print("protocol error")
				#warning("SOCKET PROTOCOL ERROR")

				networkService.refreshToken(
					token,
					username,
					callback: { _ in
						self.socketService?.reload(params: ["access_token": "\(LocalAuthService.shared.token?.accessToken ?? "")"])
					}
				)
			default:
				break
			}
		}
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocketDidReceiveMessage")
        let diffTime = Date().timeIntervalSince1970 - lastUpdateTime
        print("difftime: \(diffTime)")
        if (diffTime) >= 1 {
            lastUpdateTime = Date().timeIntervalSince1970
            updateChannels(withRequests: false)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData")
    }
    
    //MARK: - Subscribtion Methods
    
    func subscribeOnSeenMessageEvent() {
        socketService = WSService(params: ["access_token" : authService.token?.accessToken ?? ""])
        print("socket subscription: \(socketService)")
        socketService?.delegate = self
        socketService?.connectSocket()
    }
}

fileprivate extension IssueStatus {
    static var inWorkStatuses: String {
        return "\(IssueStatus.accepted),\(IssueStatus.assigned),\(IssueStatus.checking),\(IssueStatus.inModeration),\(IssueStatus.inWork),\(IssueStatus.onRoad),\(IssueStatus.reopened)"
    }
    
    static var closedStatuses: String {
        return "\(IssueStatus.closed),\(IssueStatus.completed)"
    }
    
    static var allStatuses: String {
        return IssueStatus.inWorkStatuses + "," + IssueStatus.closedStatuses
    }
}
