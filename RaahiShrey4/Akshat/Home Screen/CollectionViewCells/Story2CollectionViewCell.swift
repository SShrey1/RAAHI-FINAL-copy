
import UIKit
import SDWebImage

final class Story2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    
    private var activityIndicator: UIActivityIndicatorView!
       var currentImageURL: String?  // Keep track of the current image

       override func awakeFromNib() {
           super.awakeFromNib()
           setupActivityIndicator()
       }

       private func setupActivityIndicator() {
           activityIndicator = UIActivityIndicatorView(style: .medium)
           activityIndicator.color = .gray  // Customize color if needed
           activityIndicator.hidesWhenStopped = true
           activityIndicator.center = cellImageView.center
           cellImageView.addSubview(activityIndicator)
       }

       func setup(_ item: ListItem) {
           guard let imageURL = URL(string: item.image) else {
               cellImageView.image = UIImage(named: "placeholder")
               return
           }

           currentImageURL = item.image
           cellImageView.sd_cancelCurrentImageLoad()
           
           // Show the loading indicator
           activityIndicator.startAnimating()
           
           // Load the image with SDWebImage
           cellImageView.sd_setImage(with: imageURL, placeholderImage: nil) { [weak self] image, error, cacheType, url in
               guard let self = self else { return }
               
               // Hide the loading indicator when done
               self.activityIndicator.stopAnimating()
               
               if let downloadedImage = image, self.currentImageURL == url?.absoluteString {
                   self.cellImageView.image = downloadedImage
               } else {
                   self.cellImageView.image = UIImage(named: "placeholder")
               }
           }
       }
   }
