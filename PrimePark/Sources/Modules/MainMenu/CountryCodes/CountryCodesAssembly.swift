import UIKit

protocol CountryCodeSelectionDelegate: class {
    func select(countryCode: CountryCode)
}

final class CountryCodesAssembly: Assembly {
    private let countryCode: CountryCode
    private weak var delegate: CountryCodeSelectionDelegate?

    private(set) var scrollView: UIScrollView?

    init(countryCode: CountryCode, delegate: CountryCodeSelectionDelegate?) {
        self.countryCode = countryCode
        self.delegate = delegate
    }
    func make() -> UIViewController {
        let controller = CountryCodesViewController(
            countryCode: self.countryCode,
            delegate: delegate
        )
        self.scrollView = controller.scrollView
        return controller
    }
}
