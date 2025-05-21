

//
//final class LandscapeCollectionViewCell: UICollectionViewCell {
//    @IBOutlet weak var cellImageView: UIImageView!
//    @IBOutlet weak var cellTitleLbl: UILabel!
//    
//    
//    func setup(_ item: ListItem3) {
//            // Set the image and title
//            cellImageView.image = UIImage(named: item.image)
//            cellTitleLbl.text = item.title
//            
//            // Ensure the corner radius is applied correctly
//            cellImageView.layer.cornerRadius = 5  // Set desired corner radius
//            cellImageView.layer.masksToBounds = true // Ensures the corners are clipped
//        }
//        
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            // Apply corner radius to the entire cell if needed
//            contentView.layer.cornerRadius = 25
//            contentView.layer.masksToBounds = true
//        }
//    }

import UIKit
import SDWebImage // Add this library for easy image loading

final class LandscapeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    func setup(_ item: ListItem3) {
        // Set the title (city)
        cellTitleLbl.text = item.title
        
        // Load image from Firebase Storage URL
        if let url = URL(string: item.image) {
            cellImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")) // Use a placeholder image
        } else {
            cellImageView.image = UIImage(named: "placeholder") // Fallback if URL is invalid
        }
        
        // Ensure the corner radius is applied correctly
        cellImageView.layer.cornerRadius = 5
        cellImageView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 25
        contentView.layer.masksToBounds = true
    }
}
