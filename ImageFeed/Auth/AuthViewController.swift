import UIKit
import SnapKit

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private lazy var authImage: UIImageView = {
        let element = UIImageView()
        element.image = Resources.Images.authScreenLogo
        return element
    }()
    
    lazy var sighInButton: UIButton = {
        let element = UIButton(type: .system)
        element.backgroundColor = .ypWhite
        element.setTitle("Войти", for: .normal)
        element.setTitleColor(.ypBlack, for: .normal)
        element.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        element.layer.cornerRadius = 16
        element.layer.masksToBounds = true
        element.accessibilityIdentifier = "Authenticate"
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addViews()
    }
    
    @objc private func moveToWebView() {
        let webViewController = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewController
        webViewController.delegate = self
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

extension AuthViewController {
    private func addViews() {
        view.addSubview(authImage)
        view.addSubview(sighInButton)
        sighInButton.addTarget(self, action: #selector(moveToWebView), for: .touchUpInside)
        addConstraints()
    }
    
    private func addConstraints() {
        authImage.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.center.equalTo(view.snp.center)
        }
        
        sighInButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(90)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
