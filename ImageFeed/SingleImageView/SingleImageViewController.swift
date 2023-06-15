import UIKit
import SnapKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var imageUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addViews()
        
        showLargeImage(url: imageUrl!)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    private lazy var backButton: UIButton = {
        let element = UIButton(type: .custom)
        element.setImage(Resourses.Images.backButtonWhite, for: .normal)
        element.addTarget(self, action: #selector(backToFeed), for: .touchUpInside)
        return element
    }()
    
    private lazy var shareButton: UIButton = {
        let element = UIButton(type: .custom)
        element.setImage(Resourses.Images.shareImage, for: .normal)
        element.addTarget(self, action: #selector(share), for: .touchUpInside)
        return element
    }()
    
    private lazy var scrollView: UIScrollView = {
        let element = UIScrollView()
        return element
    }()
    
    lazy var singleImageView: UIImageView = {
        let element = UIImageView()
        return element
    }()
    
    @objc private func share() {
        guard let shareImage = singleImageView.image else { return }
        let shareController = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
        present(shareController, animated: true)
    }
    
    @objc private func backToFeed() {
        dismiss(animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.height / imageSize.height
        let wScale = visibleRectSize.width / imageSize.width
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, wScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showLargeImage(url: URL) {
        guard isViewLoaded else { return }
        UIBlockingProgressHUD.show()
        singleImageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure(_):
                self.showErrorAlert()
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так.",
                                      message: "Попробовать еще раз?",
                                      preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Повторить",
                                        style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.showLargeImage(url: self.imageUrl!)
            alert.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Не надо",
                                         style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
}

extension SingleImageViewController {
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(singleImageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
        addConstraints()
    }
    
    private func addConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        singleImageView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            make.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
        }
        
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(9)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(9)
        }
        
        shareButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(36)
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
}

