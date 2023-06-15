import UIKit

final class ProfileService: ProfileServiceProtocol {
    
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if task != nil { return }
        
        let request = makeProfileRequest(token: token)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let unsplashProfile):
                let bio = unsplashProfile.bio ?? ""
                self.profile = Profile(username: unsplashProfile.username,
                                       first_name: unsplashProfile.first_name,
                                       last_name: unsplashProfile.last_name,
                                       bio: bio)
                completion(.success(self.profile!))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}

extension ProfileService {
    func makeProfileRequest(token: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
