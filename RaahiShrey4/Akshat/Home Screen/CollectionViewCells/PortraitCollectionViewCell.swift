
import UIKit
import SDWebImage

final class PortraitCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    
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
        print("🎯 Setting up cell with Image URL: \(item.image)")

        guard let imageURL = URL(string: item.image) else {
            print("❌ Invalid Image URL: \(item.image)")
            cellImageView.image = UIImage(named: "placeholder")
            cellTitleLbl.text = item.title
            return
        }

        currentImageURL = item.image  // Track the correct image for this cell
        cellImageView.sd_cancelCurrentImageLoad()  // Cancel any old image requests
        activityIndicator.startAnimating()

        cellImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder")) { [weak self] image, error, _, url in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()

            // ✅ Ensure the image URL is still correct before updating
            if let downloadedImage = image, self.currentImageURL == url?.absoluteString {
                print("✅ Image Loaded Successfully for \(item.image)")
                self.cellImageView.image = downloadedImage
            } else {
                print("❌ Image URL changed, ignoring update")
            }

            self.cellTitleLbl.text = item.title
            self.contentView.bringSubviewToFront(self.cellTitleLbl)
        }
    }



    
}
