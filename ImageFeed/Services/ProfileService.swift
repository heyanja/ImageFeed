import UIKit

final class ProfileService {
    
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private let profileImageService = ProfileImageService.shared
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if task != nil {
            return
        }
        
        var request = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let unsplashProfile):
                let bio = unsplashProfile.bio ?? ""
                self.profile = Profile(username: unsplashProfile.username,
                                       first_name: unsplashProfile.first_name,
                                       last_name: unsplashProfile.last_name,
                                       bio: bio)
                UIBlockingProgressHUD.dismiss()
                completion(.success(self.profile!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}
