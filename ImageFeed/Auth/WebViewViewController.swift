import UIKit
import WebKit
import SnapKit

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    private let webView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addViews()
        webView.webView.navigationDelegate = self
        presenter?.viewDidLoad()
        addProgressObserver()
    }
    
    private func addProgressObserver() {
        estimatedProgressObservation = webView.webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 presenter?.didUpdateProgressValue(webView.webView.estimatedProgress)
             })
    }
    
    func load(request: URLRequest) {
        webView.webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        webView.progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        webView.progressView.isHidden = isHidden
    }
    
    static func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes,
                                                        for: [record],
                                                        completionHandler: {})
            }
        }
    }

    @objc private func backButtonAction() {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            self.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}

extension WebViewViewController {
    private func addViews() {
        view.addSubview(webView.webView)
        view.addSubview(webView.backButton)
        view.addSubview(webView.progressView)
        webView.backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        addConstraints()
    }
    
    private func addConstraints() {
        webView.webView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        webView.backButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(9)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(9)
        }
        
        webView.progressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(40)
        }
    }
}
