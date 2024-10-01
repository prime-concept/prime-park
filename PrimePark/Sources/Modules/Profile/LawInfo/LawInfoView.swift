//
//  LawInfoView.swift
//  PrimePark
//
//  Created by IvanLyuhtikov on 25.12.20.
//

protocol LawInfoViewProtocol: class {
}

final class LawInfoView: UIView {
    @IBOutlet private var ruleButtons: [LocalizableButton]!
    @IBOutlet private var ruleArrows: [UIImageView]!
    @IBOutlet private var ruleText: [LocalizableLabel]!
    @IBOutlet private var ruleViewConstraints: [NSLayoutConstraint]!
    @IBOutlet private var rateButtons: [LocalizableButton]!
    @IBOutlet private var rateArrows: [UIImageView]!
    @IBOutlet private var rateText: [LocalizableLabel]!
    @IBOutlet private var rateViewConstraints: [NSLayoutConstraint]!

    private weak var delegate: LawInfoViewProtocol?
    private var defaultViewHeight: CGFloat = 32
    private var currentRuleIndex = -1
    private var currentRateIndex = -1

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

    // MARK: - Public API

    func commonInit() {
    }

    func addDelegate(_ delegate: LawInfoViewProtocol) {
        self.delegate = delegate
    }

    // MARK: - Private API

    private func showHideTextForRule(at index: Int) {
        hideAllRules()
        if currentRuleIndex == index {
            currentRuleIndex = -1
            return
        }
        currentRuleIndex = index
        UIView.animate(withDuration: 1) {
            let labelHeight = self.heightForText(self.ruleText[index].text ?? "")
            self.ruleText[index].isHidden = false
            self.ruleViewConstraints[index].constant += (labelHeight + 20)
        }
    }

    private func hideAllRules() {
        UIView.animate(withDuration: 1) {
            for label in self.ruleText {
                label.isHidden = true
            }
            for constraint in self.ruleViewConstraints {
                constraint.constant = self.defaultViewHeight
            }
        }
    }

    private func showHideTextForRate(at index: Int) {
        hideAllRates()
        if currentRateIndex == index {
            currentRateIndex = -1
            return
        }
        currentRateIndex = index
        UIView.animate(withDuration: 1) {
            let labelHeight = self.heightForText(self.rateText[index].text ?? "")
            self.rateText[index].isHidden = false
            self.rateViewConstraints[index].constant += (labelHeight + 20)
        }
    }

    private func hideAllRates() {
        UIView.animate(withDuration: 1) {
            for label in self.rateText {
                label.isHidden = true
            }
            for constraint in self.rateViewConstraints {
                constraint.constant = self.defaultViewHeight
            }
        }
    }

    private func heightForText(_ text: String) -> CGFloat {
        let textBounds = text.boundingRect(
            with: CGSize(width: self.frame.size.width, height: 0),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: UIFont.primeParkFont(ofSize: 14)],
            context: nil
        )
        return textBounds.height
    }

    // MARK: - Actions

    @IBAction private func showHideRule(_ sender: Any) {
        guard let view: UIView = sender as? UIView else { return }
        let index = view.tag % 100
        showHideTextForRule(at: index - 1)
    }

    @IBAction private func showHideRate(_ sender: Any) {
        guard let view: UIView = sender as? UIView else { return }
        let index = view.tag % 100
        showHideTextForRate(at: index - 1)
    }
}
