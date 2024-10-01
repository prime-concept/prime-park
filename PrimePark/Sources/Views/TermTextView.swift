import UIKit
import SnapKit

fileprivate class TermTextView: UITextView {
    override var canBecomeFirstResponder: Bool {
        false
    }
}

final class TermView: UIView {
    private lazy var termsTextView = with(TermTextView()) { textView in
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.dataDetectorTypes = .link
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.linkTextAttributes = [.foregroundColor: UIColor(hex: 0xB3987A)]
    }

    var onLinkTap: ((URL) -> Void)?

    init() {
        super.init(frame: .zero)
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTerms(with text: NSAttributedString) {
        termsTextView.attributedText = text
    }
}

extension TermView: Designable {
    func addSubviews() {
        [
            self.termsTextView
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.termsTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TermView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange
    ) -> Bool {
        self.onLinkTap?(url)
        return false
    }
}
