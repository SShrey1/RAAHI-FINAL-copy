//
//  SeePostsViewController.swift
//  RaahiShrey4
//
//  Created by admin3 on 09/02/25.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class SeePostsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    var reviews = [Review]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let review = reviews[indexPath.row]
        cell.cityLabel.text = review.city
        cell.captionLabel.text = review.caption
        cell.experienceLabel.text = review.experience

        if let firstImageURL = review.imageURLs.first {
            cell.postImageView.sd_setImage(with: URL(string: firstImageURL), placeholderImage: UIImage(named: "placeholder"))
        }

        return cell
    }

    

    override func viewDidLoad() {
            super.viewDidLoad()
            postsCollection.dataSource = self
            postsCollection.delegate = self
            fetchReviewsFromFirestore()
        }
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameField: UILabel!
    
    @IBOutlet var postsCollection: UICollectionView!
    
    @IBOutlet weak var cityPosts: UITextView!
    
    @IBOutlet weak var captionPost: UITextView!
    
    @IBOutlet weak var experiencePost: UITextView!
    
   
    func fetchReviewsFromFirestore() {
           let db = Firestore.firestore()
           db.collection("reviews").order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
               if let error = error {
                   print("Error fetching reviews: \(error.localizedDescription)")
                   return
               }
               
               guard let documents = snapshot?.documents else { return }
               self.reviews = documents.compactMap { doc -> Review? in
                   let data = doc.data()
                   guard let city = data["city"] as? String,
                         let caption = data["caption"] as? String,
                         let experience = data["experience"] as? String,
                         let imageURLs = data["imageURLs"] as? [String] else {
                       return nil
                   }
                   return Review(city: city, caption: caption, experience: experience, imageURLs: imageURLs)
               }
               
               DispatchQueue.main.async {
                   self.postsCollection.reloadData()
               }
           }
       }

       // MARK: - Collection View Data Source
       
       

       // MARK: - Collection View Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 20, height: 250)
    }

   }

   // MARK: - Review Model
   struct Review {
       let city: String
       let caption: String
       let experience: String
       let imageURLs: [String]
   }

   // MARK: - Custom Collection View Cell
   class PostCollectionViewCell: UICollectionViewCell {
       @IBOutlet weak var postImageView: UIImageView!
       @IBOutlet weak var cityLabel: UILabel!
       @IBOutlet weak var captionLabel: UILabel!
       @IBOutlet weak var experienceLabel: UILabel!
   }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


