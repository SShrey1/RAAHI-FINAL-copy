
import UIKit
import FirebaseFirestore
import FirebaseStorage

final class PortraitCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    
    
//        var currentImageURL: String?
//
//        override func awakeFromNib() {
//            super.awakeFromNib()
//            
//        }
//
//    
//    func configure(with item: ListItem2) {
//            cellTitleLbl.text = item.title
//
//            guard let imageURL = URL(string: item.image) else {
//                print("⚠️ Invalid image URL: \(item.image)")
//                cellImageView.image = UIImage(named: "placeholder")
//                return
//            }
//
//            print("🖼️ Loading image from: \(imageURL)")
//
//            // Load Image Without SDWebImage
//            URLSession.shared.dataTask(with: imageURL) { data, response, error in
//                guard let data = data, error == nil, let image = UIImage(data: data) else {
//                    print("❌ Image Load Failed: \(error?.localizedDescription ?? "Unknown Error")")
//                    return
//                }
//                DispatchQueue.main.async {
//                    self.cellImageView.image = image
//                }
//            }.resume()
//        }
//
//
//    func setup(_ item: ListItem2) {
//        print("🎯 Setting up cell with Image: \(item.image), Title: \(item.title)")
//
//        guard let imageURL = URL(string: item.image) else {
//            cellImageView.image = UIImage(named: "placeholder")
//            cellTitleLbl.text = item.title
//            return
//        }
//
//        currentImageURL = item.image
//        cellImageView.sd_cancelCurrentImageLoad()
//       
//
//        cellImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder")) { [weak self] image, _, _, url in
//            guard let self = self, self.currentImageURL == url?.absoluteString else { return }
//            
//            self.cellImageView.image = image
//            self.cellTitleLbl.text = item.title
//        }
//    }
//    }
    
    
    
    
    



//    private var activityIndicator: UIActivityIndicatorView!
       var currentImageURL: String?  // Keep track of the current image

       override func awakeFromNib() {
           super.awakeFromNib()
    
       }

    func setup(_ item: ListItem2) {
            self.cellTitleLbl.text = item.title
            self.cellImageView.image = UIImage(named: "placeholder") // Show placeholder initially

            // ✅ Convert gs:// URL to HTTPS
            FirestoreHelper.shared.getDownloadURL(from: item.image) { [weak self] httpsURL in
                guard let self = self, let imageUrl = httpsURL else {
                    print("❌ Failed to convert gs:// URL")
                    return
                }

                self.loadImage(from: imageUrl)
            }
        }

        // ✅ Load Image Without SDWebImage
        private func loadImage(from urlString: String) {
            guard let url = URL(string: urlString) else {
                print("❌ Invalid image URL: \(urlString)")
                return
            }

            DispatchQueue.global(qos: .background).async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.cellImageView.image = image
                    }
                } else {
                    print("❌ Failed to load image from URL: \(urlString)")
                }
            }
        }
    }
