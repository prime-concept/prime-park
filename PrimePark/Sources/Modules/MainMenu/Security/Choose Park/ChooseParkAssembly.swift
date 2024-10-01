import UIKit

final class ChooseParkAssembly: Assembly {
    private weak var delegate: ChooseParkViewDelegate?

    init(delegate: ChooseParkViewDelegate?) {
        self.delegate = delegate
    }

    func make() -> UIViewController {
        let presenter = ChooseParkPresenter()
        let controller = ChooseParkViewController(presenter: presenter, delegate: self.delegate)
        presenter.controller = controller
        return controller
    }
}
