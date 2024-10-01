import UIKit

final class NewsDetailAssembly: Assembly {
    private var currentNews: News?

    init(news: News?) {
        self.currentNews = news
    }

    func make() -> UIViewController {
        let presenter = NewsDetailPresenter(news: self.currentNews)
        let controller = NewsDetailViewController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
