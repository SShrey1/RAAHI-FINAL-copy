
import UIKit
import FirebaseStorage
import FirebaseFirestore
import Firebase


final class Story2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLbl: UILabel!
    
    
    private let gradientLayer = CAGradientLayer() // Gradient layer

            override func awakeFromNib() {
                super.awakeFromNib()
                setupUI()
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                gradientLayer.frame = cellImageView.bounds // Ensure gradient covers image
            }

            func setupUI() {
                // ✅ Apply rounded corners
                cellImageView.layer.cornerRadius = 15
                cellImageView.layer.masksToBounds = true

                // ✅ Add a shadow effect for depth
                contentView.layer.cornerRadius = 15
                contentView.layer.shadowColor = UIColor.black.cgColor
                contentView.layer.shadowOpacity = 0.2
                contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
                contentView.layer.shadowRadius = 5
                contentView.layer.masksToBounds = false

                // ✅ Style Title Label
                cellTitleLbl.textAlignment = .left
                cellTitleLbl.textColor = .white
                cellTitleLbl.font = .boldSystemFont(ofSize: 20)
                
                // ✅ Add gradient overlay
                addGradientOverlay()
            }

            private func addGradientOverlay() {
                gradientLayer.colors = [
                    UIColor.black.withAlphaComponent(0.6).cgColor, // Dark at the bottom
                    UIColor.clear.cgColor // Transparent at the top
                ]
                gradientLayer.locations = [0.0, 1.0] // Gradient transition
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0) // Start from bottom
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)   // End at top
                gradientLayer.frame = cellImageView.bounds
                
                cellImageView.layer.addSublayer(gradientLayer)
            }

            func setup(_ item: ListItem) {
                print("🎯 Setting up cell with Firestore Image: \(item.image)")

                self.cellTitleLbl.text = item.title
                self.cellImageView.image = UIImage(named: "placeholder") // ✅ Placeholder

                // ✅ Convert gs:// URL to HTTPS
                FirestoreHelper.shared.getDownloadURL(from: item.image) { [weak self] url in
                    guard let self = self, let url = url, let imageURL = URL(string: url) else { return }
                    
                    DispatchQueue.global(qos: .background).async {
                        if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                UIView.transition(with: self.cellImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                                    self.cellImageView.image = image
                                }, completion: { _ in
                                    self.gradientLayer.frame = self.cellImageView.bounds // Update gradient after image loads
                                })
                            }
                        } else {
                            print("❌ Failed to load image from URL: \(url)")
                        }
                    }
                }
            }
        }
