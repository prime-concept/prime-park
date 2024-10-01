import Foundation

final class NewsEndpoint: PrimeParkEndpoint {
    private static let newsListEndpoint = "/primepark/news/"

    func getNewsList(
        token: String,
        room: String,
        count: Int = 10,
        offset: Int
    ) -> EndpointResponse<[News]> {
        print(token)
        let endRequestString = Self.newsListEndpoint + room
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        var params: [String: Any] = [:]
        params["count"] = count
        params["offset"] = offset
        return self.retrieve(endpoint: endRequestString, parameters: params, headers: headers)
    }
}
