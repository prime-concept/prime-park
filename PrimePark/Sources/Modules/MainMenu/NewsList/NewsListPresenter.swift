import Foundation

protocol NewsListPresenterProtocol {
    func refresh(with offset: Int)
    func select(itemAt index: Int)
}

final class NewsListPresenter: NewsListPresenterProtocol {
    weak var controller: NewsListViewProtocol?

    private var endpoint: NewsEndpoint
    private var localAuthService = LocalAuthService.shared
    private var networkService = NetworkService()

    private var newsList: [News]? = []

    init(endpoint: NewsEndpoint) {
        self.endpoint = endpoint
    }

    func refresh(with offset: Int) {
        self.getNewses(with: offset)
    }

    func select(itemAt index: Int) {
        print(self.newsList?[index])
        let assembly = NewsDetailAssembly(news: self.newsList?[index])
        let router = ModalRouter(source: self.controller, destination: assembly.make())
        router.route()
    }

    func getNewses(with offset: Int) {
        guard let room = self.localAuthService.apartment else { return }
        
        networkService.request(
			accessToken: self.localAuthService.token?.accessToken ?? "",
            requestCompletion: { accessToken in
                self.endpoint.getNewsList(token: accessToken, room: String(room.id), offset: offset)
            },
            doneCompletion: { news in
                print(news)
                self.newsList?.append(contentsOf: news)
                self.controller?.set(data: news)
            },
            errorCompletion: { error in
                print("ERROR WHILE GET NEWSES: \(error.localizedDescription)")
            }
        )
    }
}
