import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView = WKWebView()
    
    var stringURL = ""
    var isNavigationBarHidden: Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        
        guard let url = URL(string: stringURL) else { return }
        var request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        makeConstraints()
    }
    
    init(stringURL: String, isNavigationBarHidden: Bool = false) {
        self.stringURL = stringURL
        self.isNavigationBarHidden = isNavigationBarHidden
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WebViewController: Designable {
    func setupView() {
    }
    
    func addSubviews() {
        view.addSubview(webView)
    }
    
    func makeConstraints() {
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
