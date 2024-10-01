import UIKit

final class FullImageAssembly: Assembly {
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    func make() -> UIViewController {
        FullImageViewController(image: self.image)
    }
}
