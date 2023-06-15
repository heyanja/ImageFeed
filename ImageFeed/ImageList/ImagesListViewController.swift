import UIKit
import SnapKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    var presenter: ImagesListPresenterProtocol?
    private var photosServiceObserver: NSObjectProtocol?
    
    private lazy var tableView: UITableView = {
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
        presenter?.photosObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.imagesListService?.fetchPhotosNextPage()
        presenter?.updateTableView()
    }
    
    private func addConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func requestFullSizeImage(viewController: SingleImageViewController, url: URL) {
        UIBlockingProgressHUD.show()
        viewController.singleImageView.kf.setImage(
            with: url) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let imageResult):
                        UIBlockingProgressHUD.dismiss()
                        viewController.rescaleAndCenterImageInScrollView(image: imageResult.image)
                    case .failure(_:):
                        UIBlockingProgressHUD.dismiss()
                        viewController.showErrorAlert()
                    }
                }
            }
    }
    
    func switchToSingleViewController(sender: Any?) {
        let singleImageViewController = SingleImageViewController()
        guard let indexPath = sender as? IndexPath,
              let photoURL = presenter?.photos[indexPath.row].largeImageURL else { return }

        if let url = URL(string: photoURL) {
            requestFullSizeImage(viewController: singleImageViewController, url: url)
        }
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let date = presenter?.photos[indexPath.row].createdAt,
              let isLiked = presenter?.photos[indexPath.row].isLiked else { return }
        cell.dateLabel.text = dateToStringFormatter(date: date)
        cell.delegate = self
        let likeImage = isLiked ? Resourses.Images.activeLike : Resourses.Images.noActiveLike
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switchToSingleViewController(sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else { return 100 }
        let image = presenter.photos[indexPath.row]
        
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
        guard let photos = presenter?.photos.count else { return 0 }
        return photos
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesListCell", for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        guard let photoURL = presenter?.photos[indexPath.row].thumbImageURL else { return UITableViewCell() }
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
        if indexPath.row + 1 == presenter?.photos.count {
            UIBlockingProgressHUD.show()
            presenter?.imagesListService?.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let presenter = presenter else { return }
        let photo = presenter.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        presenter.imagesListService?.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self,
                  let imagesListService = presenter.imagesListService else { return }
            switch result {
            case .success():
                presenter.photos = imagesListService.photos
                cell.setLiked(presenter.photos[indexPath.row].isLiked)
            case .failure(let error):
                print(error)
                self.presenter?.showAlert(vc: self)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
}


