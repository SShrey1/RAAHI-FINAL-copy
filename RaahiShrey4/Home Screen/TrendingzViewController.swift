//
//  TrendingzViewController.swift
//  RaahiShrey4
//
//  Created by admin3 on 07/02/25.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class TrendingzViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView! // Connect this to the UIScrollView in the storyboard
    @IBOutlet weak var contentView: UIView! // Connect this to the content view inside the UIScrollView
    
    @IBOutlet weak var imageTrendz: UIImageView!
    @IBOutlet weak var aboutTrendz: UILabel!
    @IBOutlet weak var descTrendz: UILabel!
    @IBOutlet weak var activitiesTrendz: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    
    var selectedTrendingTitle: String?  // Title passed from HomePageViewController
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure image view
        imageTrendz.layer.cornerRadius = 1
        imageTrendz.clipsToBounds = true
        
        // Configure descTrendz label
        descTrendz.numberOfLines = 0 // Allow unlimited lines
        descTrendz.lineBreakMode = .byWordWrapping // Wrap text by words
        descTrendz.textAlignment = .justified // Justify text alignment
        
        // Fetch trending details if a title is provided
        if let title = selectedTrendingTitle {
            print("📢 Fetching Trending Data for Title: \(title)")
            fetchTrendingDetails(for: title)  // Fetch data based on title
        } else {
            print("⚠️ No title received in TrendingzViewController")
        }
    }
    
    private func fetchTrendingDetails(for title: String) {
        FirestoreHelper.shared.fetchTrendingItem(by: title) { [weak self] item in
            guard let self = self, let item = item else {
                print("❌ No data found for title: \(title)")
                return
            }
            
            print("✅ Fetched Trending Details: \(item.title)")
            
            DispatchQueue.main.async {
                // Update the aboutTrendz label (if needed)
                // self.aboutTrendz.text = item.title
                
                // Update the descTrendz label with the fetched data
                self.descTrendz.text = item.about // Show about field
                
                // Fetch and display the image
                FirestoreHelper.shared.getDownloadURL(from: item.image) { imageURL in
                    if let imageURL = imageURL, let url = URL(string: imageURL) {
                        DispatchQueue.global(qos: .background).async {
                            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.imageTrendz.image = image
                                }
                            }
                        }
                    } else {
                        print("⚠️ Image URL not found or invalid")
                    }
                }
            }
        }
    }
}
