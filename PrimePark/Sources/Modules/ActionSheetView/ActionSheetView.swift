import UIKit

protocol ActionSheetViewDelegate: class {
    func didChoose(item: Int)
}

final class ActionSheetView: UIView {

    @IBOutlet private weak var actionStackView: UIStackView!

    private weak var actionSheetDelegate: ActionSheetViewDelegate?
    private var actionViewArray: [ActionSheetContentView] = []

    // MARK: - Initialization

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    init(delegate: ActionSheetViewDelegate) {
        self.actionSheetDelegate = delegate
        super.init(frame: .zero)
    }

    // MARK: - Public API

    func commonInit() {
    }

    func addDelegate(delegate: ActionSheetViewDelegate) {
        self.actionSheetDelegate = delegate
    }

    func setStartIndex(_ index: Int) {
        enableViewWith(index: index)
    }

    func addActions(_ actions: [String]) {
        for action in actions {
            let actionView = Bundle.main.loadNibNamed("ActionSheetContentView", owner: nil, options: nil)?.first as? ActionSheetContentView ?? ActionSheetContentView()
            actionView.addDelegate(self)
            actionView.setTitle(action)
            actionViewArray.append(actionView)
            actionStackView.addSubview(actionView)
        }
    }

    // MARK: - Private API

    private func enableViewWith(index: Int) {
        for actionView in actionViewArray {
            actionView.setEnable(false)
        }
        actionViewArray[index].setEnable(true)
    }
}

extension ActionSheetView: ActionSheetContentViewDelegate {
    func didChoose(item: ActionSheetContentView) {
        let index = actionViewArray.firstIndex(of: item) ?? 0
        enableViewWith(index: index)
        self.actionSheetDelegate?.didChoose(item: index)
    }
}
