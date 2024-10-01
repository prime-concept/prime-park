import UIKit

enum AlertStatus: Int {
    case success = 0
    case failure
}

final class InfoAssembly: Assembly {
    private let status: AlertStatus
    private let title: String
    private let subtitle: String?
    private weak var delegate: InfoControllerProtocol?

    init(title: String, subtitle: String?, delegate: InfoControllerProtocol?, status: AlertStatus = .success) {
        self.title = title
        self.subtitle = subtitle
        self.delegate = delegate
        self.status = status
    }

    func make() -> UIViewController {
        let presenter = InfoPresenter(
            title: self.title,
            subtitle: self.subtitle,
            status: status
        )
        let controller = InfoViewController(
            presenter: presenter,
            title: self.title,
            subtitle: self.subtitle,
            delegate: self.delegate,
            status: status
        )
        presenter.controller = controller
        return controller
    }
}
