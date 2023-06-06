import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_vc: AuthViewController,
    didAuthenticateWithCode code: String)
}
