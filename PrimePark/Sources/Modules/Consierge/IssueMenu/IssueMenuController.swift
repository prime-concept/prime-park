//
//  IssueMenuController.swift
//  PrimePark
//
//  Created by Vanjo Lutik on 04.03.2021.
//
//swiftlint:disable all
import UIKit
import ChatSDK

protocol IssueMenuControllerProtocol: ModalRouterSourceProtocol {
}

final class IssueMenuController: UIViewController, IssueMenuControllerProtocol {
    private lazy var issueMenuView = view as? IssueMenuView
    
    var presenter: IssueMenuPresenterProtocol?
    
    override func loadView() {
        view = IssueMenuView(frame: .zero)
        issueMenuView?.delegate = self
    }
    
}

extension IssueMenuController: IssueMenuViewDelegate {
    func didTap(item: HomeItemType) {
        presenter?.createIssue(item)
    }
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
}
