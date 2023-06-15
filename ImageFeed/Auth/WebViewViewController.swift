import UIKit
import WebKit
import SnapKit

final class WebViewViewController: UIViewController {
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    
    private lazy var webView: WKWebView = {
        let element = WKWebView()
        element.backgroundColor = .ypWhite
        return element
    }()
    
    private lazy var backButton: UIButton = {
        let element = UIButton(type: .system)
        element.setImage(Resources.Images.backButtonBlack, for: .normal)
        element.tintColor = .ypBlack
        element.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return element
    }()
    
    private lazy var progressView: UIProgressView = {
        let element = UIProgressView()
        element.progressTintColor = .ypBlack
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addViews()
        webView.navigationDelegate = self
        requestToUnsplash()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateProgress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressView.isHidden = true
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func requestToUnsplash() {
        guard var urlComponents = URLComponents(string: Constants.authorizeURl) else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: Parameters.client_id, value: Constants.accessKey),
            URLQueryItem(name: Parameters.redirect_uri, value: Constants.redirectURI),
            URLQueryItem(name: Parameters.response_type, value: Parameters.code),
            URLQueryItem(name: Parameters.scope, value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)
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
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == Constants.urlPathToAuthorize,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == Parameters.code })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

extension WebViewViewController {
    private func addViews() {
        view.addSubview(webView)
        view.addSubview(backButton)
        view.addSubview(progressView)
        addConstraints()
    }
    
    private func addConstraints() {
        webView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(9)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(9)
        }
        
        progressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(40)
        }
    }
}
