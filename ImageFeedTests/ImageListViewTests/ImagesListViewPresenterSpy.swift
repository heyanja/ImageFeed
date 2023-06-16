import UIKit
@testable import ImageFeed

final class ImagesListViewPresenterSpy: ImagesListPresenterProtocol {
    var photos: [ImageFeed.Photo] = []
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var imagesListService: ImageFeed.ImagesListServiceProtocol?
    var viewDidLoad: Bool = false
    var showErrorAlert: Bool = false
    var presenteredVC: UIViewController?
    var newUpdateTableView: Bool = false
    
    func photosObserver() {
        viewDidLoad = true
    }
    
    func updateTableView() {
        newUpdateTableView = true
    }
    
    func showAlert(vc: UIViewController) {
        showErrorAlert = true
        presenteredVC = vc
    }
    
    func addPhotos() {
        let date = stringToDateFormatter(string: "2001-01-01T11:00:00-01:00")
        let photo = Photo(id: "id",
                          size: CGSize(width: 30, height: 30),
                          createdAt: date,
                          welcomeDescription: "Hello everyone",
                          thumbImageURL: "thumb",
                          largeImageURL: "large",
                          isLiked: true)
        photos.append(photo)
    }
}

