import Foundation

protocol InfoPresenterProtocol {
}

final class InfoPresenter: InfoPresenterProtocol {
    private let title: String
    private let subtitle: String?
    private var status: AlertStatus

    weak var controller: InfoControllerProtocol?

    init(title: String, subtitle: String?, status: AlertStatus = .success) {
        self.title = title
        self.subtitle = subtitle
        self.status = status
    }
}
