import Foundation

struct Constants {
    static let accessKey = "23VXHOCzn2P1SK1i8mUFFH4g0Hb_NnMEvfLfwmqAk0U"
    static let secretKey = "oGMX76ng8RNuzJoPxDX0vPGf7Ugnoyzj6s66SFAQkU4"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseUrl = URL(string: "https://api.unsplash.com")!
    static let authorizeURl = "https://unsplash.com/oauth/authorize"
    static let urlPathToAuthorize = "/oauth/authorize/native"
    static let urlToFetchAuthToken = "https://unsplash.com/oauth/token"
}
struct Parameters {
    static let client_id = "client_id"
    static let client_secret = "client_secret"
    static let redirect_uri = "redirect_uri"
    static let response_type = "response_type"
    static let code = "code"
    static let scope = "scope"
    static let grantType = "grant_type"
    static let authorizationCode = "authorization_code"
}
