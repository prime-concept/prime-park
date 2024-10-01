import Foundation

struct DetailHeaderViewModel {
    let title: String?
    let subtitle: String?
    let image: String?

    var imageURL: URL? {
        guard let url = URL(string: image ?? "") else {
            return nil
        }

        return url
    }
}
