import Foundation

protocol ChooseParkPresenterProtocol {
}

final class ChooseParkPresenter: ChooseParkPresenterProtocol {
    weak var controller: ChooseParkViewProtocol?

    init() {}
}
