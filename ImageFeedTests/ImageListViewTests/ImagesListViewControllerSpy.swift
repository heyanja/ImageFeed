import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImagesListPresenterProtocol?
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        
    }
}
