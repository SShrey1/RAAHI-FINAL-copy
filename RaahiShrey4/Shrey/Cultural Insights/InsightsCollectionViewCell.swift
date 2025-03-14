//
//  InsightsCollectionViewCell.swift
//  RaahiShrey4
//
//  Created by user@59 on 21/08/1946 Saka.
//

import UIKit
import FirebaseStorage
import Kingfisher

class InsightsCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var insiteView: UIView!
    @IBOutlet weak var insiteImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    func setup3(with insite: Insite) {
            NameLabel.text = insite.title
            typeLabel.text = insite.type
            priceLabel.text = insite.price

            // Convert Firebase Storage gs:// URL to HTTPS URL
            if insite.imageURL.starts(with: "gs://") {
                let storageRef = Storage.storage().reference(forURL: insite.imageURL)
                storageRef.downloadURL { [weak self] url, error in
                    if let error = error {
                        print("❌ Error fetching image URL: \(error.localizedDescription)")
                        self?.insiteImage.image = UIImage(named: "placeholder")
                        return
                    }
                    if let url = url {
                        self?.insiteImage.kf.setImage(
                            with: url,
                            placeholder: UIImage(named: "placeholder"),
                            options: [
                                .transition(.fade(0.3)),
                                .cacheOriginalImage
                            ]
                        )
                    }
                }
            } else if let imageURL = URL(string: insite.imageURL) {
                insiteImage.kf.setImage(
                    with: imageURL,
                    placeholder: UIImage(named: "placeholder"),
                    options: [
                        .transition(.fade(0.3)),
                        .cacheOriginalImage
                    ]
                )
            } else {
                insiteImage.image = UIImage(named: "placeholder")
            }

            // Image Styling
            insiteImage.layer.cornerRadius = 15
            insiteImage.layer.masksToBounds = true

            // View Styling
            insiteView.layer.cornerRadius = 15
            insiteView.layer.masksToBounds = true
            insiteView.layer.borderWidth = 1
            insiteView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
