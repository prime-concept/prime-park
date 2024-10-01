import UIKit

protocol ChooseParkViewProtocol: AnyObject {}

private enum ParkType {
    case fruit
    case central
    case art
    case sport
}

final class ChooseParkViewController: UIViewController {
    private lazy var chooseParkView: ChooseParkView = {
        let view = Bundle.main.loadNibNamed("ChooseParkView", owner: nil, options: nil)?.first as? ChooseParkView ?? ChooseParkView(delegate: self)
        return view
    }()
    private let presenter: ChooseParkPresenterProtocol
    private weak var delegate: ChooseParkViewDelegate?

    init(presenter: ChooseParkPresenterProtocol, delegate: ChooseParkViewDelegate?) {
        self.presenter = presenter
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.chooseParkView
        self.chooseParkView.setDelegate(delegate: self)
        chooseParkView.commonInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        chooseParkView.commonInit()
    }
}

extension ChooseParkViewController: ChooseParkViewDelegate {
    func parkDidChoose(park: Int) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UserDidChoosePark"), object: nil, userInfo: ["choosenPark": park])
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChooseParkViewController: ChooseParkViewProtocol {}
