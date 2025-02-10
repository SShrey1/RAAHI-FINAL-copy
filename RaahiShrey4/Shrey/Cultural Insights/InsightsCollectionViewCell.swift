//
//  InsightsCollectionViewCell.swift
//  RaahiShrey4
//
//  Created by user@59 on 21/08/1946 Saka.
//

import UIKit
import Kingfisher

class InsightsCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var insiteView: UIView!
    
    @IBOutlet weak var insiteImage: UIImageView!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    
    func setup3(with insite: Insite) {
        // Load image from Assets folder
        insiteImage.image = UIImage(named: insite.imageURL) ?? UIImage(named: "placeholder") // Use placeholder if image not found
        
        if let image = UIImage(named: insite.imageURL) {
            print("✅ Successfully loaded image: \(insite.imageURL)")
        } else {
            print("❌ Failed to load image: \(insite.imageURL)")
        }
        
        NameLabel.text = insite.title
        typeLabel.text = insite.type
        priceLabel.text = insite.price
        
        // Image Styling
        insiteImage.layer.cornerRadius = 20
        insiteImage.layer.masksToBounds = true
        
        // View Styling
        insiteView.layer.cornerRadius = 20
        insiteView.layer.masksToBounds = true
    }

    }
