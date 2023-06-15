import UIKit
import Kingfisher

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    private var photosServiceObserver: NSObjectProtocol?
    var imagesListService: ImagesListServiceProtocol?
    
    var photos: [Photo] = []
    
    func photosObserver() {
        photosServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableView()
            }
    }
    
    func updateTableView() {
        guard let imagesListService = imagesListService else { return }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func showAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Попробуйте позднее",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Нет", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
}
