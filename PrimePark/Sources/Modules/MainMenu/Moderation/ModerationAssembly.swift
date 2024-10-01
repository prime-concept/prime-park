final class ModerationAssembly: Assembly {
    private let pass: Pass?
    init(pass: Pass?) {
        self.pass = pass
    }
    func make() -> UIViewController {
        let presenter = ModerationPresenter()
        let controller = ModerationController(presenter: presenter, pass: pass)
        controller.presenter = presenter
        return controller
    }
}
