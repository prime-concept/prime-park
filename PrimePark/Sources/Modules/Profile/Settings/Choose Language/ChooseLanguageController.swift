import UIKit

protocol ChooseLanguageControllerProtocol: class {
}

class ChooseLanguageController: PannableViewController {
    private var presenter: ChooseLanguagePresenterProtocol
    private lazy var chooseLanguageView: ChooseLanguageView = {
        let view = Bundle.main.loadNibNamed("ChooseLanguageView", owner: nil, options: nil)?.first as? ChooseLanguageView ?? ChooseLanguageView(delegate: self)
        return view
    }()
    override func loadView() {
        self.view = chooseLanguageView
        self.chooseLanguageView.addDelegate(delegate: self)
        self.chooseLanguageView.commonInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chooseLanguageView.currentLanguage = LocalAuthService.shared.choosenLanguage ?? .russian
    }
    init(presenter: ChooseLanguagePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChooseLanguageController: ChooseLanguageControllerProtocol {
}

extension ChooseLanguageController: ChooseLanguageViewDelegate {
    func pickLanguage(language: Language) {
        presenter.pickLanguage(language: language)
    }
}
