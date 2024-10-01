//
//  IssueMenuAssembly.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 04.03.2021.
//
//swiftlint:disable all
import ChatSDK

final class IssueMenuAssembly: Assembly {
    
    var fromViewController: PushRouterSourceProtocol & ChannelModuleOutputProtocol & LoadableWithButton
    
    init(fromVC: PushRouterSourceProtocol & ChannelModuleOutputProtocol & LoadableWithButton) {
        fromViewController = fromVC
    }
    
    func make() -> UIViewController {
        let controller = IssueMenuController()
        let presenter = IssueMenuPresenter()
        controller.presenter = presenter
        presenter.controller = controller
        presenter.fromVC = fromViewController
        return controller
    }
}
