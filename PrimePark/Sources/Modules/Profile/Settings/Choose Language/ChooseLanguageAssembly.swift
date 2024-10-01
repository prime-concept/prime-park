import UIKit

final class ChooseLanguageAssembly: Assembly {
    private weak var delegate: ChooseLanguageViewDelegate?

    init(delegate: ChooseLanguageViewDelegate?) {
        self.delegate = delegate
    }

    func make() -> UIViewController {
        let presenter = ChooseLanguagePresenter()
        let controller = ChooseLanguageController(presenter: presenter)
        presenter.controller = controller
        return controller
    }
}
