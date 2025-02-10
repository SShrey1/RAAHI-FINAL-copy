//
//  PostReviewViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 16/12/2024.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

class PostReviewViewController: UIViewController {

    @IBOutlet weak var PostCollectionView: UICollectionView!
    var imageArray = [UIImage]()
    var uploadedImageURLs = [String]()
    
    
    @IBOutlet weak var txtexperience: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtCaption: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func uploadBtnTapped(_ sender: Any) {
        
        guard let city = txtCity.text, !city.isEmpty,
                      let caption = txtCaption.text, !caption.isEmpty,
                      let experience = txtexperience.text, !experience.isEmpty else {
                    showAlert(title: "Error", message: "All fields are required!")
                    return
                }

                guard !imageArray.isEmpty else {
                    showAlert(title: "Error", message: "Please select at least one image!")
                    return
                }
                
                showAlert(title: "Uploading", message: "Your review is being uploaded.")
                
                uploadImages { [weak self] imageURLs in
                    guard let self = self else { return }
                    
                    if imageURLs.isEmpty {
                        self.showAlert(title: "Error", message: "Image upload failed. Please try again.")
                        return
                    }
                    
                    let reviewData: [String: Any] = [
                        "city": city,
                        "caption": caption,
                        "experience": experience,
                        "imageURLs": imageURLs,
                        "timestamp": FieldValue.serverTimestamp()
                    ]
                    
                    self.saveReviewToFirestore(reviewData: reviewData)
                }
            }
    
    
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        var config = PHPickerConfiguration()
                config.selectionLimit = 7
                config.filter = .images // Ensuring only images can be selected
                
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                present(picker, animated: true)
            }
            
            private func uploadImages(completion: @escaping ([String]) -> Void) {
                let storageRef = Storage.storage().reference().child("post_images")
                var uploadedURLs = [String]()
                let dispatchGroup = DispatchGroup()
                
                for image in imageArray {
                    guard let imageData = image.jpegData(compressionQuality: 0.75) else { continue }
                    let imageName = UUID().uuidString
                    let imageRef = storageRef.child("\(imageName).jpg")
                    
                    dispatchGroup.enter()
                    imageRef.putData(imageData, metadata: nil) { _, error in
                        if let error = error {
                            print("Error uploading image: \(error.localizedDescription)")
                        } else {
                            imageRef.downloadURL { url, error in
                                if let downloadURL = url {
                                    uploadedURLs.append(downloadURL.absoluteString)
                                } else {
                                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                                }
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(uploadedURLs)
                }
            }
            
            private func saveReviewToFirestore(reviewData: [String: Any]) {
                let db = Firestore.firestore()
                db.collection("reviews").addDocument(data: reviewData) { error in
                    if let error = error {
                        self.showAlert(title: "Error", message: "Failed to save review: \(error.localizedDescription)")
                    } else {
                        self.showAlert(title: "Success", message: "Your review has been uploaded successfully!")
                        self.clearFields()
                    }
                }
            }
            
            private func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
            
            private func clearFields() {
                txtCity.text = ""
                txtCaption.text = ""
                txtexperience.text = ""
                imageArray.removeAll()
                PostCollectionView.reloadData()
            }
        }

        extension PostReviewViewController: PHPickerViewControllerDelegate {
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                dismiss(animated: true)
                
                for result in results {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.imageArray.append(image)
                                self.PostCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }

        extension PostReviewViewController: UICollectionViewDataSource {
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

        extension PostReviewViewController: UICollectionViewDelegateFlowLayout {
            func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.height / 3 - 1)
            }
            
            func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
                return 1
            }
            
            func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
                return 1
            }
        }

