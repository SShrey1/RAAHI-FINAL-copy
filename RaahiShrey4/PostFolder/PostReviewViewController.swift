//
//  PostReviewViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 16/12/2024.
//

import UIKit
import PhotosUI

class PostReviewViewController: UIViewController {

    @IBOutlet weak var PostCollectionView: UICollectionView!
    var imageArray = [UIImage]()
    
    
    @IBOutlet weak var txtexperience: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtCaption: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func uploadBtnTapped(_ sender: Any) {
        
        let dict = ["city":txtCity.text, "caption":txtCaption.text, "experience":txtexperience.text]
        DatabaseHelper.sharedInstance.save(object: dict as! [String:String])
    }
    
    
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        
        //PhotoPicker
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 7
        
        let phPickerVC = PHPickerViewController(configuration: config)
        self.present(phPickerVC,animated: true)
        phPickerVC.delegate = self
        
    }
    
}

extension PostReviewViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    self.imageArray.append(image)
                }
                
                DispatchQueue.main.async {
                    self.PostCollectionView.reloadData()
                }
            }
        }
    }
}


extension PostReviewViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostReviewCollectionViewCell", for: indexPath) as? PostReviewCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.PostReviewImage.image = imageArray[indexPath.row]
        return cell
    }
}

extension PostReviewViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.size.width / 3 - 2, height: collectionView.frame.size.height / 5 - 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
}
