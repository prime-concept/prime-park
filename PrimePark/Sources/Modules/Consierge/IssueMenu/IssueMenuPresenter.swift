//
//  IssueMenuPresenter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 04.03.2021.
//
//swiftlint:disable all
import ChatSDK

protocol IssueMenuPresenterProtocol {
    func createIssue(_ item: HomeItemType)
}

final class IssueMenuPresenter: IssueMenuPresenterProtocol {
    weak var controller: IssueMenuControllerProtocol?
    var fromVC: (PushRouterSourceProtocol & ChannelModuleOutputProtocol & LoadableWithButton)?
    
    let networkService = NetworkService()
    
    func createIssue(_ item: HomeItemType) {
        switch item {
        case .cleaning:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.cleaning.rawValue, title: .cleaning)
            }
        case .services:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.services.rawValue, title: .services)
            }
        case .different:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.different.rawValue, title: .different)
            }
        case .parking:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.parking.rawValue, title: .parking)
            }
        case .charges:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.charges.rawValue, title: .charges)
            }
        case .drycleaning:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.dryCleaning.rawValue, title: .drycleaning)
            }
        case .carwash:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.carWash.rawValue, title: .carwash)
            }
        case .pass:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.pass.rawValue, title: .pass)
            }
        case .security:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.security.rawValue, title: .security)
            }
        case .help:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.help.rawValue, title: .help)
            }
        default:
            self.controller?.dismiss {
                self.fromVC?.requestButton.startButtonLoadingAnimation(loadingTitle: "Загрузка")
                self.fromVC?.triggerLoading()
                self.createIssueForChat(with: ChatIdIssue.help.rawValue, title: .help)
            }
        }
    }
}

extension IssueMenuPresenter: SingleChatInteractionProtocol {
    func openChat(with id: String, title: String) {
        let authService = LocalAuthService.shared
        guard
            let from = fromVC,
            let username = authService.user?.username, !username.isEmpty,
            let token = authService.token?.accessToken, !token.isEmpty
        else { return }
        let chatController = ChatAssembly(
            chatToken: token,
            channelID: "PPI\(id)",
            channelName: title,
            clientID: "C\(username)",
            item: nil,
            sourceViewController: from
        ).make()
        
        PushRouter(source: from, destination: chatController).route()
    }
    
    func createIssueForChat(with type: String, title: HomeItemType) {
        guard
            let type = IssuesTypeService.shared.getType(at: type),
            let room = LocalAuthService.shared.apartment,
            let token = LocalAuthService.shared.token?.accessToken
        else { return }
        
        networkService.request(
			accessToken: token,
            requestCompletion: { accessToken in
                self.issueEndpoint.createIssue(
                    room: room.id,
                    text: localizedWith("\(title.title)"),
                    type: type,
                    token: accessToken
                )
            },
            doneCompletion: { issue in
                self.openChat(with: issue.id, title: localizedWith(title.title))
            },
            errorCompletion: { error in
                print("ERROR WHILE CREATE SECURITY CHAT ISSUE: \(error.localizedDescription)")
            }
        )
    }
}
