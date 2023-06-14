import UIKit
import SnapKit

final class SingleImageViewController: UIViewController {
    
    private lazy var backButton: UIButton = {
        let element = UIButton(type: .custom)
        element.setImage(UIImage(named: "chevron.backward"), for: .normal)
        element.addTarget(self, action: #selector(backToFeed), for: .touchUpInside)
        return element
    }()

    private lazy var shareButton: UIButton = {
        let element = UIButton(type: .custom)
        element.setImage(UIImage(named: "Sharing"), for: .normal)
        element.addTarget(self, action: #selector(share), for: .touchUpInside)
        return element
    }()

    private lazy var scrollView: UIScrollView = {
        let element = UIScrollView()
        return element
    }()

    private lazy var singleImageView: UIImageView = {
        let element = UIImageView()
        return element
    }()
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            singleImageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(singleImageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
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
    
    @objc private func share() {
        guard let shareImage = image else { return }
        let shareController = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
        present(shareController, animated: true)
    }
    
    @objc private func backToFeed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addViews()
        addConstraints()
        
        singleImageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
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
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
}
