import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // webView.navigationDelegate = self
        requestToUnsplash()
    
    }
    

    @IBAction private func didTapBackButton(_ sender: Any?) {
        
    }
    
    private func requestToUnsplash() {
        let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
        var urlComponents = URLComponents(string: unsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        let url = urlComponents.url!
        
        let request = URLRequest(url: url)
        webView.load(request)
        
    }

    
}


