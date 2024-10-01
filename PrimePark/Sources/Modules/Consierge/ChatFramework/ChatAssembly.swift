import ChatSDK
import UIKit

final class ChatAssembly: Assembly {
    private lazy var chatConfiguration = Chat.Configuration(
        chatBaseURL: Config.chatBaseURL,
        storageBaseURL: Config.chatStorageURL,
        initialTheme: Theme(
            palette: ChatPalette(),
            imageSet: ChatImageSet(),
            styleProvider: ChatStyleProvider(),
            fontProvider: ChatFontProvider(),
            layoutProvider: ChatLayoutProvider()
        ),
        featureFlags: Chat.Configuration.FeatureFlags.all(),
        clientAppID: Config.chatClientAppID
    )

    private let sourceViewController: ChannelModuleOutputProtocol

    private let chatToken: String
    private let channelID: String
    private let channelName: String
    private let clientID: String
    private let chatItem: Issue?
    
    private let titleView: UIView?

    init(
        chatToken: String,
        channelID: String,
        channelName: String,
        clientID: String,
        item: Issue?,
        sourceViewController: ChannelModuleOutputProtocol,
        titleView: UIView? = nil
    ) {
        self.chatToken = chatToken
        self.channelID = channelID
        self.channelName = channelName
        self.clientID = clientID
        self.chatItem = item
        self.sourceViewController = sourceViewController
        self.titleView = titleView
    }

    func make() -> UIViewController {
        let chat = Chat(
            configuration: self.chatConfiguration,
            accessToken: self.chatToken,
            clientID: self.clientID
        )
        let channelModule = chat.makeChannelModule(
            for: self.channelID,
            output: self.sourceViewController
        )
        
        let channelViewController = channelModule.viewController
        channelViewController.title = self.channelName
        channelViewController.navigationItem.titleView = titleView

        return channelViewController
    }
}
