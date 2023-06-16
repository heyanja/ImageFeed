import Foundation

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest {
        let url = authURL()
        return URLRequest(url: url)
    }
    
    func authURL() -> URL {
        var urlComponents = URLComponents(string: configuration.authURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: Parameters.client_id, value: configuration.accessKey),
            URLQueryItem(name: Parameters.redirect_uri, value: configuration.redirectURI),
            URLQueryItem(name: Parameters.response_type, value: Parameters.code),
            URLQueryItem(name: Parameters.scope, value: configuration.accessScope)
        ]
        let url = urlComponents.url!
        return url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
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
