import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    
    private let imagesListService = ImagesListService.shared
    private var photosServiceObserver: NSObjectProtocol?
    
    private var photos: [Photo] = []
    
    private lazy var tableView: UITableView! = {
        let element = UITableView()
        element.backgroundColor = .ypBlack
        element.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        element.register(ImagesListCell.self, forCellReuseIdentifier: "ImagesListCell")
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        addConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
        photosObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imagesListService.fetchPhotosNextPage()
        updateTableViewAnimated()
    }
    
    private func addConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func photosObserver() {
        photosServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
    }
    
    private func switchToSingleViewController(sender: Any?) {
        let singleImageViewController = SingleImageViewController()
        guard let indexPath = sender as? IndexPath else { return }
        
        let photoURL = photos[indexPath.row].largeImageURL
        if let url = URL(string: photoURL) {
            singleImageViewController.imageUrl = url
            singleImageViewController.singleImageView.kf.indicatorType = .activity
        }
        singleImageViewController.singleImageView.kf.indicatorType = .none
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let date = photos[indexPath.row].createdAt else { return }
        cell.dateLabel.text = dateToStringFormatter(date: date)
        cell.delegate = self
        let isLiked = photos[indexPath.row].isLiked
        let likeImage = isLiked ? Resourses.Images.activeLike : Resourses.Images.noActiveLike
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switchToSingleViewController(sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesListCell", for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        let photoURL = photos[indexPath.row].thumbImageURL
        if let url = URL(string: photoURL) {
            imageListCell.cellImage.kf.setImage(with: url, placeholder: Resourses.Images.imagesPlaceHolder) { _ in
                imageListCell.cellImage.kf.indicatorType = .activity
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController {
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success():
                self.photos = self.imagesListService.photos
                cell.setLiked(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                print(error)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
}

