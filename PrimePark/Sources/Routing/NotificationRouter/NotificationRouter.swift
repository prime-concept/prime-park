//
//  NotificationRouter.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 12.05.2021.
//
// swiftlint:disable colon trailing_whitespace
import Foundation
import ChatSDK

protocol NotificationRouterProtocol {
    func toNews()
    func toChat(id: String)
    func toConcierge()
}

final class NotificationRouter: SourcelessRouter, NotificationRouterProtocol {
    func toChat(id: String) {
        toConcierge()
        
        let authService = LocalAuthService.shared
        
        guard let username = authService.user?.username, !username.isEmpty,
            let token = authService.token?.accessToken, !token.isEmpty
        else {
            fatalError("User doesn`t exist")
        }
        
        print(topController)
        
        guard let sourceController = topController as? (ChannelModuleOutputProtocol & PushRouterSourceProtocol) else { return }
        
        print(id)
        
        let chatController = ChatAssembly(
            chatToken: token,
            channelID: "PPI\(id)",
            channelName: /*item.typeDesctiption*/"Chat",
            clientID: "C\(username)",
            item: nil,
            sourceViewController: sourceController
        ).make()

        //let navCon = sourceController.navigationController
        //let navItem = navCon?.navigationItem

        chatController.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(
            //image: UIImage(named: "chat_security")?.withRenderingMode(.alwaysOriginal),
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        //titleView.setData(item: item)
        //chatController.navigationController?.navigationItem.titleView = self.titleView
        //chatController.navigationController?.navigationBar.prefersLargeTitles = false
        PushRouter(source: sourceController, destination: chatController).route()
    }
    
    func toConcierge() {
        let tabRouter = TabBarRouter(tab: 1)
        tabRouter.route()
    }
    
    func toNews() {
        let tabRouter = TabBarRouter(tab: 0)
        tabRouter.route()
        PushRouter(source: nil, destination: NewsListAssembly().make()).route()
    }
}
