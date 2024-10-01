import Foundation

protocol ChooseLanguagePresenterProtocol {
    func pickLanguage(language: Language)
}

final class ChooseLanguagePresenter: ChooseLanguagePresenterProtocol {
    weak var controller: ChooseLanguageControllerProtocol?

    init() {}
    func pickLanguage(language: Language) {
        LocalAuthService.shared.changeChoosenLanguage(language)
    }
}
