import UIKit
import WebKit

final class WebView {
    lazy var webView: WKWebView = {
        let element = WKWebView()
        element.backgroundColor = .ypWhite
        element.accessibilityIdentifier = "UnsplashWebView"
        return element
    }()
    
    lazy var backButton: UIButton = {
        let element = UIButton(type: .system)
        element.setImage(Resources.Images.backButtonBlack, for: .normal)
        element.tintColor = .ypBlack
        return element
    }()
    
    lazy var progressView: UIProgressView = {
        let element = UIProgressView()
        element.progressTintColor = .ypBlack
        return element
    }()
}
