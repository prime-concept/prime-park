import UIKit

protocol InfoControllerProtocol: class {
    func controllerDidClose()
}

final class InfoViewController: UIViewController {
    private lazy var error = self.view as? InfoView
    private let presenter: InfoPresenterProtocol
    private weak var delegate: InfoControllerProtocol?
    private let titleText: String
    private let subtitleText: String?
    private var status: AlertStatus = .success

    init(presenter: InfoPresenterProtocol, title: String, subtitle: String?, delegate: InfoControllerProtocol?, status: AlertStatus = .success) {
        self.presenter = presenter
        self.titleText = title
        self.subtitleText = subtitle
        self.delegate = delegate
        self.status = status
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = InfoView(delegate: self, title: self.titleText, subtitle: self.subtitleText)
    }
}

extension InfoViewController: InfoViewDelegate {
    func onBackButtonTap() {
        if status == .success {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension InfoViewController: InfoControllerProtocol {
    func controllerDidClose() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
