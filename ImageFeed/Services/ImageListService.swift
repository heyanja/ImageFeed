import Foundation

final class ImagesListService: ImagesListServiceProtocol {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        
        assert(Thread.isMainThread)
        if task != nil { return }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        var request = URLRequest.makeHTTPRequest(path: "/photos/?page=\(nextPage)", httpMethod: "GET")
        request.setValue("Bearer \(OAuth2TokenStorage().token!)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photosResult):
                photosResult.forEach { photo in
                    let date = stringToDateFormatter(string: photo.createdAt)
                    guard let thumbImage = photo.urls?.thumb,
                          let fullImage = photo.urls?.full else { return }
                    self.photos.append(Photo(id: photo.id,
                                             size: CGSize(width: photo.width, height: photo.height),
                                             createdAt: date,
                                             welcomeDescription: photo.description ?? "",
                                             thumbImageURL: thumbImage,
                                             largeImageURL: fullImage,
                                             isLiked: photo.likedByUser))
                }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["Photos": self.photos])
                self.task = nil
                self.lastLoadedPage = nextPage
                UIBlockingProgressHUD.dismiss()
            case .failure(_):
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if likeTask != nil { return }
        
        let method = isLike ? "POST" : "DELETE"
        
        var request = URLRequest.makeHTTPRequest(path: "/photos/\(photoId)/like", httpMethod: method)
        request.setValue("Bearer \(OAuth2TokenStorage().token!)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeRequest, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let likeResponce):
                if let index = self.photos.firstIndex(where: { $0.id == photoId}) {
                    let likeChange = likeResponce.photo
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id,
                                         size: photo.size,
                                         createdAt: photo.createdAt,
                                         welcomeDescription: photo.welcomeDescription,
                                         thumbImageURL: photo.thumbImageURL,
                                         largeImageURL: photo.largeImageURL,
                                         isLiked: likeChange.likedByUser)
                    self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    self.likeTask = nil
                    completion(.success(()))
                }
            case .failure(let error):
                self.likeTask = nil
                completion(.failure(error))
            }
        }
        self.likeTask = task
        task.resume()
    }
}
