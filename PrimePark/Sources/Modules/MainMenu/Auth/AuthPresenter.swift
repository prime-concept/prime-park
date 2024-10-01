import Foundation

protocol AuthPresenterProtocol {
    func sendPhone(with phone: String)
    func call()
    func becomeResident()
}

final class AuthPresenter: AuthPresenterProtocol {
    private let companyPhone = "+74954812244"
    private let endpoint: AuthEndpoint

    weak var controller: AuthViewProtocol?

    init(endpoint: AuthEndpoint) {
        self.endpoint = endpoint
    }

    func sendPhone(with phone: String) {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.endpoint.register(phone: phone).result
        }.done { [weak self] _ in
            guard let controller = self?.controller else {
                return
            }
            let assembly = VerificationAssembly(phone: phone)
            let router = PushRouter(source: controller, destination: assembly.make())
            router.route()
        }.catch { error in
            print("ERROR WHILE REGISTER:\(error.localizedDescription)")
            self.controller?.unblockButton()
        }
    }

    func call() {
        if let phone = URL(string: "tel://\(companyPhone)"),
            UIApplication.shared.canOpenURL(phone) {
            UIApplication.shared.open(phone)
        }
    }

    // swiftlint:disable force_unwrapping
    func becomeResident() {
        let url = URL(string: "https://primepark.ru")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
