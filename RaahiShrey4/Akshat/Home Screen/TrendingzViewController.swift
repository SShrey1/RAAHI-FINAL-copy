//
//  TrendingzViewController.swift
//  RaahiShrey4
//
//  Created by admin3 on 07/02/25.
//

import UIKit

class TrendingzViewController: UIViewController {

    @IBOutlet weak var imageTrendz: UIImageView!
    
    @IBOutlet weak var aboutTrendz: UILabel!
    
    @IBOutlet weak var descTrendz: UITextView!
    
    
    @IBOutlet weak var activitiesTrendz: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var button3: UIButton!
    
    @IBOutlet weak var button4: UIButton!
    
    @IBOutlet weak var button5: UIButton!
    
//    var selectedStory: StoryItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTrendz.layer.cornerRadius = 10
            imageTrendz.clipsToBounds = true

        // Do any additional setup after loading the view.
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
