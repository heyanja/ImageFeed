import UIKit
import SnapKit

final class ImagesListCell: UITableViewCell {
    
    lazy var cellImage: UIImageView = {
        let element = UIImageView()
        element.contentMode = .scaleAspectFill
        element.layer.cornerRadius = 16
        element.layer.masksToBounds = true
        return element
    }()
    
    lazy var dateLabel: UILabel = {
        let element = UILabel()
        element.textColor = .ypWhite
        element.font = UIFont.systemFont(ofSize: 13)
        return element
    }()
    
    lazy var likeButton: UIButton = {
        let element = UIButton(type: .custom)
        element.setImage(UIImage(named: "No Active"), for: .normal)
        return element
    }()
    
    lazy var gradientImageView: UIImageView = {
        let element = UIImageView()
        return element
    }()

    override func layoutSubviews() {
        gradientImageView.layer.sublayers = nil
        contentView.addSubview(cellImage)
        contentView.addSubview(gradientImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)
        addConstraints()
        setupGradient()
        
    }
    
    func addConstraints() {
        cellImage.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView).inset(4)
            make.trailing.leading.equalTo(contentView).inset(16)
        }

        likeButton.snp.makeConstraints { make in
            make.top.equalTo(cellImage).inset(12)
            make.trailing.equalTo(cellImage).inset(10.5)
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(cellImage).inset(8)
            make.trailing.greaterThanOrEqualTo(cellImage)
        }

        gradientImageView.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.bottom.trailing.leading.equalTo(cellImage)
        }
    }
    
    func setupGradient() {
        let height = gradientImageView.bounds.height
        let width = gradientImageView.bounds.width
        
        let colorTop = UIColor.ypBlack.withAlphaComponent(0.0).cgColor
        let colorBottom = UIColor.ypBlack.withAlphaComponent(0.2).cgColor
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradient.colors = [colorTop, colorBottom]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradientImageView.layer.addSublayer(gradient)
    }
}
