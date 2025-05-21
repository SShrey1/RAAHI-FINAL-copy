//
//  CustomTableViewCell1.swift
//  RAAHI
//
//  Created by admin3 on 05/11/24.
//

import UIKit

class CustomTableViewCell1: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var Title1: UILabel!
    
    @IBOutlet weak var Title2: UILabel!
    @IBOutlet weak var Title3: UILabel!
    
    var addAction: (() -> Void)?
    
    @IBAction func addButton(_ sender: Any) {
        showPopup(button: sender as! UIButton)
    }
    
    private func showPopup(button: UIButton) {
            let alert = UIAlertController(
                title: "Where do you want to save this itinerary?",
                message: nil,
                preferredStyle: .alert
            )

            let saveAction = UIAlertAction(title: "My Itinerary", style: .default) { _ in
                self.addAction?() // Call the add function from ViewController
                button.setImage(UIImage(named: "tick"), for: .normal)
                button.isEnabled = false
            }
            alert.addAction(saveAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            self.window?.rootViewController?.present(alert, animated: true)
        }
    }
