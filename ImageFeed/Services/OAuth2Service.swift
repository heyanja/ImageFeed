import Foundation

final class OAuth2Service: OAuth2ServiceProtocol {
    
    func fetchAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
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
        
        let task = URLSession.shared.dataTask(with: request) { data, responce, error in
            if let data = data,
               let responce = responce,
               let statusCode = (responce as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    if let json = try? JSONDecoder().decode(OAuthTokenResponseBody.self, from: data) {
                        DispatchQueue.main.async {
                            OAuth2TokenStorage().token = json.accessToken
                            handler(.success(json.accessToken))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        handler(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    guard let error = error else { return }
                    handler(.failure(NetworkError.urlRequestError(error)))
                }
            }
        }
        task.resume()
    }
}
