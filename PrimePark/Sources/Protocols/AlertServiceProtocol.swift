
protocol AlertServiceProtocol {
    func present(
        _ title: String,
        with content: [String],
        didTapHandler: @escaping Handler
    )
    typealias Handler = (_ title: String) -> Void
}

extension AlertServiceProtocol where Self: ModalRouterSourceProtocol {
    func present(
        _ title: String,
        with content: [String],
        didTapHandler: @escaping Handler
    ) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.view.layer.cornerRadius = 22
        alert.view.tintColor = .white
        for type in content {
            let action = UIAlertAction(title: type, style: .default) {
                didTapHandler($0.title ?? "")
            }
            alert.addAction(action)
        }
        present(module: alert)
    }
}
