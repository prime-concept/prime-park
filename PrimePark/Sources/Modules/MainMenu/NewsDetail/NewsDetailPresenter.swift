import Foundation

protocol NewsDetailPresenterProtocol {
    func refresh()
}

final class NewsDetailPresenter: NewsDetailPresenterProtocol {
    weak var controller: NewsDetailViewProtocol?
    private var currentNews: News?

    init(news: News?) {
        self.currentNews = news
    }

    func refresh() {
        self.controller?.set(viewModel: self.currentNews)
    }
}
