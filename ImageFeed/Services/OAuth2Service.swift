import Foundation

final class OAuth2Service: OAuth2ServiceProtocol {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        guard var urlComponents = URLComponents(string: Constants.urlToFetchAuthToken) else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: Parameters.client_id, value: Constants.accessKey),
            URLQueryItem(name: Parameters.client_secret, value: Constants.secretKey),
            URLQueryItem(name: Parameters.redirect_uri, value: Constants.redirectURI),
            URLQueryItem(name: Parameters.code, value: code),
            URLQueryItem(name: Parameters.grantType, value: Parameters.authorizationCode)
        ]
        
        guard let url = urlComponents.url else { return }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                guard let authToken = body.accessToken else { return }
                OAuth2TokenStorage().token = authToken
                self.task = nil
                completion(.success(authToken))
            case .failure(let error):
                self.lastCode = nil
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}

