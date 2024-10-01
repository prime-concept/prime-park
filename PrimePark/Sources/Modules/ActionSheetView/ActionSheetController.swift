import UIKit

protocol ActionSheetControllerDelegate: class {
    func choosenItem(index: Int)
}

final class ActionSheetController: UIViewController {
    private lazy var actionSheetView: ActionSheetView = {
        let view = Bundle.main.loadNibNamed("ActionSheetView", owner: nil, options: nil)?.first as? ActionSheetView ?? ActionSheetView(delegate: self)
        return view
    }()

    private weak var delegate: ActionSheetControllerDelegate?

    init(delegate: ActionSheetControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = actionSheetView
        actionSheetView.addDelegate(delegate: self)
        actionSheetView.commonInit()
    }

    func addActions(_ actions: [String]) {
        self.actionSheetView.addActions(actions)
    }
}

extension ActionSheetController: ActionSheetViewDelegate {
    func didChoose(item: Int) {
        self.delegate?.choosenItem(index: item)
        self.dismiss(animated: true, completion: nil)
    }
}
