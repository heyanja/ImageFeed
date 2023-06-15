import XCTest
@testable import ImageFeed

final class ImagesListViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidload() {
        //given
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        presenter.view = imagesListViewController
        imagesListViewController.presenter = presenter
        //when
        _ = imagesListViewController.view
        //then
        XCTAssertTrue(presenter.viewDidLoad)
    }
    
    func testPhotosDownLoaded() {
        //given
        let presenter = ImagesListViewPresenterSpy()
        //when
        presenter.photosObserver()
        //then
        XCTAssertNotNil(presenter.photos)
    }
    
    func testErrorAlert() {
        //given
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        //when
        presenter.showAlert(vc: imagesListViewController)
        //then
        XCTAssertTrue(presenter.showErrorAlert)
        XCTAssertEqual(presenter.presenteredVC, imagesListViewController)
    }
    
    func testUpdateTableView() {
        //given
        let presenter = ImagesListViewPresenterSpy()
        //when
        presenter.updateTableView()
        //then
        XCTAssertTrue(presenter.newUpdateTableView)
    }
    
    func testNumberOfRowsInSection() {
        //given
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        let tableView = UITableView()
        //when
        let count = imagesListViewController.tableView(tableView, numberOfRowsInSection: presenter.photos.count)
        //then
        XCTAssertEqual(count, 0)
    }
    
    func testNumberOfRowsInSectionSetup() {
        //given
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        imagesListViewController.presenter = presenter
        let tableView = UITableView()
        //when
        presenter.addPhotos()
        let count = imagesListViewController.tableView(tableView, numberOfRowsInSection: presenter.photos.count)
        //then
        XCTAssertNotEqual(count, 0)
    }
    
    func testCellForRowAt() {
        //given
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        imagesListViewController.presenter = presenter
        let imagesListCell = ImagesListCell()
        imagesListCell.delegate = imagesListViewController
        let tableView = UITableView()
        //when
        //presenter.addPhotos()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: "ImagesListCell")
        let cell = imagesListViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        //then
        XCTAssertEqual(cell.reuseIdentifier, "ImagesListCell")
    }
    
    func testImageListCellDidTapLike() {
        //given
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        let imagesListCell = ImagesListCell()
        imagesListCell.delegate = imagesListViewController
        //when
        presenter.addPhotos()
        imagesListViewController.imageListCellDidTapLike(imagesListCell)
        let likePhoto = presenter.photos[0].isLiked
        //then
        XCTAssertEqual(likePhoto, presenter.photos[0].isLiked)
    }
    
    func testHeightForRowAt() {
        //given
        let imagesListViewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        imagesListViewController.presenter = presenter
        let tableView = UITableView()
        //when
        presenter.addPhotos()
        let result = imagesListViewController.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        //then
        XCTAssertNotEqual(result, 100)
    }
}
