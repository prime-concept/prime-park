import WebKit

protocol GuideViewProtocol: class {
}

final class GuideView: UIView {
    @IBOutlet private weak var webView: WKWebView!

    private weak var delegate: GuideViewProtocol?
    private var token = ""
    private let apiKey = "b35cbd04-e4ea-4555-bb35-d7cd92fc39f2"

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

    init(delegate: GuideViewProtocol) {
        self.delegate = delegate
        super.init(frame: .zero)
    }

    // MARK: - Public API

    // swiftlint:disable force_unwrapping
    func commonInit() {
        webView.navigationDelegate = self
        let url = URL(string: "https://prime.travel?env=webview&app_key=\(apiKey)&auth_token=\(token)&prefix=PrimePark")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    func addDelegate(delegate: GuideViewProtocol) {
        self.delegate = delegate
    }

    func addData(token: String) {
        self.token = token
    }
}

extension GuideView: WKNavigationDelegate {
}
