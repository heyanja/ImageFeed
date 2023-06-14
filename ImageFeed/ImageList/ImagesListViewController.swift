import UIKit

final class ImagesListViewController: UIViewController {
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var tableView: UITableView = {
        let element = UITableView()
        element.backgroundColor = .ypBlack
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        addConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: "ImagesListCell")
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func addConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func switchToSingleViewController(sender: Any?) {
        let singleImageViewController = SingleImageViewController()
        guard let indexPath = sender as? IndexPath else { return }
        let image = UIImage(named: photosName[indexPath.row])
        singleImageViewController.image = image
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photoIndex = photosName[indexPath.row]
        let image = UIImage(named: photoIndex)
        
        guard let photo = image else { return }
        cell.cellImage.image = photo
        cell.dateLabel.text = Date().currentDate
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.setImage(UIImage(named: "Active"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "No Active"), for: .normal)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switchToSingleViewController(sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
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
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesListCell", for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
