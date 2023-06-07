import Foundation

protocol OAuth2ServiceProtocol {
    func fetchAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) -> Void
}
