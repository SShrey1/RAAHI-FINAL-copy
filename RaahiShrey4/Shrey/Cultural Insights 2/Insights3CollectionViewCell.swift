//
//  Insights3CollectionViewCell.swift
//  RaahiShrey4
//
//  Created by user@59 on 26/08/1946 Saka.
//

import UIKit
import SDWebImage

class Insights3CollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var insiteView: UIView!
    
    @IBOutlet weak var insiteImage: UIImageView!
    
    @IBOutlet weak var insiteName: UILabel!
    
    @IBOutlet weak var insiteType: UILabel!
    
    @IBOutlet weak var insiteCost: UILabel!
    
    func setup3(with insite: Insite) {
        if let url = URL(string: insite.imageURL) {
            insiteImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            insiteImage.image = UIImage(named: "placeholder") // Fallback image
        }

        insiteName.text = insite.title
        insiteType.text = insite.type
        insiteCost.text = insite.price

        insiteImage.layer.cornerRadius = 20
        insiteImage.layer.masksToBounds = true

        insiteView.layer.cornerRadius = 20
        insiteView.layer.masksToBounds = true
    }
}

