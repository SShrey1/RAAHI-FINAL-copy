//
//  CategoriesCollectionViewCell.swift
//  RaahiShrey4
//
//  Created by user@59 on 21/08/1946 Saka.
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typeNameLabel: UILabel!
    
    
    func setup(with selection : Selection) {
        typeImageView.image = selection.image
        typeNameLabel.text = selection.title
        
        typeImageView.layer.cornerRadius = typeImageView.frame.height / 2
        typeImageView.clipsToBounds = true
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        typeImageView.layer.cornerRadius = typeImageView.frame.height / 2
        typeImageView.clipsToBounds = true
    }
    
    
}
