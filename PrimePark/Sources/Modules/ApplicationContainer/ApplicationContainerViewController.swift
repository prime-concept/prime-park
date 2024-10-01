import UIKit

protocol ApplicationContainerViewProtocol: class {
    func displayModule(assembly: Assembly)
}

final class ApplicationContainerViewController: UIViewController {
    private let presenter: ApplicationContainerPresenterProtocol

    private var currentChild: UIViewController?

    init(presenter: ApplicationContainerPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.presenter.didLoad()
    }

    private func displayChild(viewController childViewController: UIViewController) {
        self.addChild(childViewController)

        self.view.addSubview(childViewController.view)
        childViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        childViewController.didMove(toParent: self)

        self.currentChild?.view.removeFromSuperview()
        self.currentChild?.removeFromParent()

        self.currentChild = childViewController
    }
}

extension ApplicationContainerViewController: ApplicationContainerViewProtocol {
    func displayModule(assembly: Assembly) {
        self.displayChild(viewController: assembly.make())
    }
}
