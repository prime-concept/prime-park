import UIKit

protocol ActionSheetContentViewDelegate: class {
    func didChoose(item: ActionSheetContentView)
}

final class ActionSheetContentView: UIView {

    private let disableColor = UIColor(hex: 0x828082)

    @IBOutlet private weak var titleLabel: LocalizableLabel!
    @IBOutlet private weak var checkmarkImageView: UIImageView!

    private weak var delegate: ActionSheetContentViewDelegate?

    func addDelegate(_ delegate: ActionSheetContentViewDelegate) {
        self.delegate = delegate
    }

    func setEnable(_ enable: Bool) {
        self.titleLabel.textColor = enable ? .white : disableColor
        self.checkmarkImageView.isHidden = !enable
    }

    func setTitle(_ title: String) {
        self.titleLabel.text = title
    }

    @IBAction private func viewDidSelect(_ sender: Any) {
    }
}
