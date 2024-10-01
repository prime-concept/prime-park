import UIKit

final class NewsListAssembly: Assembly {
    func make() -> UIViewController {
        let presenter = NewsListPresenter(endpoint: NewsEndpoint())
        let controller = NewsListViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
