import Foundation

protocol ProfileServiceProtocol: AnyObject {
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}
