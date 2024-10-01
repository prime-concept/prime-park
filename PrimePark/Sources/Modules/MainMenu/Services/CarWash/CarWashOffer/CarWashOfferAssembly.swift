import UIKit

final class CarWashOfferAssembly: Assembly {
    private var onCloseCompletion: (() -> Void)

    init(onCloseCompletion: @escaping () -> Void) {
        self.onCloseCompletion = onCloseCompletion
    }

    func make() -> UIViewController {
        let controller = CarWashOfferViewController(onCloseCompletion: onCloseCompletion)
        return controller
    }
}



