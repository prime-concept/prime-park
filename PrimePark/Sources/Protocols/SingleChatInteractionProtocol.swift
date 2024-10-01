import ChatSDK

protocol SingleChatInteractionProtocol: class {
    func openChat(with id: String)
    func createIssueForChat(with type: String, title: HomeItemType)
    func checkForNotClosed(completionHandler: @escaping ([Issue]?) -> Void)
    var issueEndpoint: IssuesEndpoint { get }
}

extension SingleChatInteractionProtocol {
    func openChat(with id: String) {}
    func checkForNotClosed(completionHandler: @escaping ([Issue]?) -> Void) {}
    func createIssueForChat(with type: String, title: HomeItemType) {}
}

extension SingleChatInteractionProtocol {
    var issueEndpoint: IssuesEndpoint {
        return IssuesEndpoint()
    }
}

protocol InfoAlertProtocol: class {
    func showSuccessAlert()
    func showErrorAlert()
}

extension InfoAlertProtocol where Self: UIViewController {
    internal func showSuccessAlert() {
        let assembly = InfoAssembly(title: Localization.localize("service.orderService.success.title"), subtitle: nil, delegate: nil)
        let router = ModalRouter(source: self, destination: assembly.make())
        router.route()
    }

    internal func showErrorAlert() {
        let assembly = InfoAssembly(title: Localization.localize("service.orderService.error.title"), subtitle: Localization.localize("service.orderService.error.subtitle"), delegate: nil)
        let router = ModalRouter(source: self, destination: assembly.make())
        router.route()
    }
}
