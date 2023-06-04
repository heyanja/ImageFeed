import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet private var gradientImageView: UIImageView!
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func layoutSubviews() {
        gradientImageView.layer.sublayers = nil
        setupGradient()
    }
    
    override func prepareForReuse() {
        gradientImageView.layer.sublayers = nil
    }
    
    func setupGradient() {
        let height = gradientImageView.bounds.height
        let width = gradientImageView.bounds.width
        
        let colorTop = UIColor.ypBlack.withAlphaComponent(0.0).cgColor
        let colorBottom = UIColor.ypBlack.withAlphaComponent(0.2).cgColor
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x:0, y:0, width: width, height: height)
        gradient.colors = [colorTop, colorBottom]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradientImageView.layer.addSublayer(gradient)
        
    }
}
