//
//  HighlightsViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 25/08/1946 Saka.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class HighlightsViewController: UIViewController {
    
    struct Highlight {
        let title: String
        let imageURL: String
        let description: String
    }

    var selectedTitle: String?  // This will hold the passed data
    
    @IBOutlet weak var highImageView: UIImageView!
    @IBOutlet weak var highLbl: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
        
        if let title = selectedTitle {
            fetchHighlightDetails(for: title)
        }
        
        // Add tap gesture to the image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        highImageView.isUserInteractionEnabled = true
        highImageView.addGestureRecognizer(tapGesture)
    }
    
    private func styleUI() {
        // Round image with shadow
        highImageView.layer.cornerRadius = 1
        highImageView.clipsToBounds = true
        highImageView.layer.shadowColor = UIColor.black.cgColor
        highImageView.layer.shadowOpacity = 0.3
        highImageView.layer.shadowOffset = CGSize(width: 3, height: 3)
        highImageView.layer.shadowRadius = 5
        
        // Label Styling
        highLbl.font = UIFont.boldSystemFont(ofSize: 22)
        highLbl.textAlignment = .center
        
        descLabel.font = UIFont.systemFont(ofSize: 16)
        descLabel.textAlignment = .justified  // Set alignment to justified
        descLabel.numberOfLines = 0
    }
    
    private func fetchHighlightDetails(for title: String) {
        db.collection("highlights")
            .whereField("title", isEqualTo: title)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("❌ Error fetching highlight details: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("❌ No highlight found for title: \(title)")
                    return
                }

                let data = document.data()
                let title = data["title"] as? String ?? "No Title"
                let imagePath = data["imageURL"] as? String ?? ""
                let description = data["description"] as? String ?? "No Description"
                
                let highlight = Highlight(title: title, imageURL: imagePath, description: description)
                
                DispatchQueue.main.async {
                    self.updateUI(with: highlight)
                }
            }
    }
    
    private func updateUI(with highlight: Highlight) {
        highLbl.text = highlight.title
        
        // Set justified alignment for description text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributedString = NSAttributedString(
            string: highlight.description,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        
        descLabel.attributedText = attributedString
        
        if highlight.imageURL.hasPrefix("gs://") {
            fetchImageURL(from: highlight.imageURL) { [weak self] downloadURL in
                guard let self = self else { return }
                if let downloadURL = downloadURL {
                    self.highImageView.loadImage(from: downloadURL)
                }
            }
        }
    }
    
    private func fetchImageURL(from gsURL: String, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: gsURL)
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("❌ Error getting download URL: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(url)
            }
        }
    }
    
    // MARK: - Fullscreen Image Handling
    @objc private func imageTapped() {
        guard let image = highImageView.image else { return }
        
        // Create a new view controller for fullscreen image
        let fullscreenVC = FullscreenImageViewController()
        fullscreenVC.image = image
        
        // Present the fullscreen image view controller
        fullscreenVC.modalPresentationStyle = .fullScreen
        present(fullscreenVC, animated: true, completion: nil)
    }
}

// MARK: - Fullscreen Image View Controller
class FullscreenImageViewController: UIViewController {
    
    var image: UIImage?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Add image view
        view.addSubview(imageView)
        imageView.frame = view.bounds
        imageView.image = image
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissFullscreenImage() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Image Loading Extension
extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
