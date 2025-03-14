//
//  Custom1TableViewCell.swift
//  CustomTableView
//
//  Created by User@Param on 29/10/24.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class ParamTableViewCell: UITableViewCell {
    @IBOutlet weak var  iconImageView: UIImageView!
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label12: UILabel!
    @IBOutlet weak var label13: UILabel!
    @IBOutlet weak var label14: UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           
           // ✅ Rounded Corners for ImageView
           iconImageView.layer.cornerRadius = 10
           iconImageView.clipsToBounds = true
       }


}
