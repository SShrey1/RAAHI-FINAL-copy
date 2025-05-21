//
//  ShowPostViewController.swift
//  RaahiShrey4
//
//  Created by admin3 on 09/02/25.
//

import UIKit

class ShowPostViewController: UIViewController {
    
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var post1: UIImageView!
    
    
    @IBOutlet weak var city: UILabel!
    
    
    @IBOutlet weak var cityFetch: UITextView!
    
    @IBOutlet weak var caption: UILabel!
    
    @IBOutlet weak var captionFetch: UITextView!
    
    @IBOutlet weak var exp: UILabel!
    
    
    @IBOutlet weak var expFetch: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.layer.cornerRadius = image.frame.size.width / 2
                image.clipsToBounds = true
                
                // Making the second image (post1) slightly curved
                post1.layer.cornerRadius = 10  // Adjust the corner radius to your liking
                post1.clipsToBounds = true
        

        // Do any additional setuview.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
