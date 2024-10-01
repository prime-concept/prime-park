import UIKit
import WebKit

// swiftlint:disable trailing_whitespace force_unwrapping
class WebDepositController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var webView = WKWebView()
    
    var stringUrl: String
    var isNavigationBarHidden: Bool
    var depositController: DepositControllerProtocol?
    
    private var observer: NSKeyValueObservation?
    
    init(stringUrl: String, isNavigationBarHidden: Bool = false) {
        self.stringUrl = stringUrl
        self.isNavigationBarHidden = isNavigationBarHidden
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubviews()
        self.loadRequest()
        observer = webView.observe(\.url, options: .new) { (_, change) in
            guard let changedUrl = change.newValue,
                  let strUrl = changedUrl?.absoluteString,
                  strUrl.contains("https://primepark.ru/")
            else { return }

            self.pop()
        }
    }
    
    override func viewDidLayoutSubviews() {
        makeConstraints()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        parent == nil ? depositController?.checkDeposit() : ()
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popup = WKWebView(frame: view.bounds, configuration: configuration)
        popup.uiDelegate = self
        popup.navigationDelegate = self

        view.addSubview(popup)

        return popup
    }
    
    private func getPostString(params: [String: String]) -> String {
        var data = [String]()
        for(key, value) in params {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    private func loadRequest() {
        guard let stringEncoded = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let fullUrl = URL(string: stringEncoded) else {
            return
        }
        var request = URLRequest(url: fullUrl.deleteParams())
        let body = fullUrl.getParams()
        let json = getPostString(params: body)
        
        guard let data = json.data(using: .utf8) else {
            return
        }
        request.httpBody = data
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        webView.load(request)
    }
}

extension WebDepositController: Designable {
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

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}

extension URL {
  func getParams() -> [String: String] {
      var dict = [String: String]()
      if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
          if let queryItems = components.queryItems {
              queryItems.compactMap { item in
                  dict[item.name] = item.value
              }
          }
          return dict
      } else {
          return [:]
      }
  }
    
    func deleteParams() -> URL {
        let urlComponents = NSURLComponents(url: self, resolvingAgainstBaseURL: false)
        urlComponents?.query = nil
        if let url = URL(string: urlComponents?.string ?? "") {
            return url
        } else {
            return self
        }
    }
}
