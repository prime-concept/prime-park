import Foundation

final class OfferService {
    private let defaults = UserDefaults.standard
    private let didShowOfferKey = "didShowonbardingKey"

    private var didShowOffer: Bool {
        get {
            return defaults.value(forKey: self.didShowOfferKey) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: self.didShowOfferKey)
        }
    }

    var shouldShowOffer: Bool {
        return !didShowOffer
    }

    func showOnboarding(
        onCloseCompletion: @escaping (() -> Void)
    ) -> CarWashOfferAssembly {
        didShowOffer = true
        return CarWashOfferAssembly(
            onCloseCompletion: onCloseCompletion
        )
    }
}
