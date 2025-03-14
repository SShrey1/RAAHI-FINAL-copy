import UIKit
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PHPickerViewControllerDelegate, UITextViewDelegate {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var selectedImages: [UIImage] = [] {
        didSet {
            // Reload the collection view and update the UI layout when images are added or removed
            imageCollectionView.reloadData()
            updateUILayout()
        }
    }
    
    let cityTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter City"
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height)) // Add left margin
        textField.leftViewMode = .always
        return textField
    }()
    
    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Date (DD-MM-YYYY)"
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height)) // Add left margin
        textField.leftViewMode = .always
        return textField
    }()
    
    let experienceTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Write your experience..."
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textColor = .lightGray
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 8) // Add left margin
        textView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return textView
    }()
    
    let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Images", for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 25)
        return button
    }()
    
    
    let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 25)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 120) // Increased image size
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Add subviews to the stack view
        stackView.addArrangedSubview(cityTextField)
        stackView.addArrangedSubview(dateTextField)
        stackView.addArrangedSubview(experienceTextView)
        stackView.addArrangedSubview(addImageButton)
        stackView.addArrangedSubview(uploadButton)
        stackView.addArrangedSubview(activityIndicator)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cityTextField.heightAnchor.constraint(equalToConstant: 50),
            dateTextField.heightAnchor.constraint(equalToConstant: 50),
            experienceTextView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        experienceTextView.delegate = self
        
        addImageButton.addTarget(self, action: #selector(selectImages), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadData), for: .touchUpInside)
    }
    
    // MARK: - Update UI Layout
    func updateUILayout() {
        if selectedImages.isEmpty {
            // Hide the collection view if no images are selected
            imageCollectionView.removeFromSuperview()
        } else {
            // Show the collection view at the top of the stack view if images are selected
            if imageCollectionView.superview == nil {
                stackView.insertArrangedSubview(imageCollectionView, at: 0)
                imageCollectionView.heightAnchor.constraint(equalToConstant: 130).isActive = true
            }
        }
    }
    
    // MARK: - Image Picker
    @objc func selectImages() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let group = DispatchGroup()
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self, let image = image as? UIImage else {
                    group.leave()
                    return
                }
                DispatchQueue.main.async {
                    self.selectedImages.append(image)
                }
                group.leave()
            }
        }
    }
    
    // MARK: - Upload Data
    @objc func uploadData() {
        guard let city = cityTextField.text, !city.isEmpty,
              let date = dateTextField.text, !date.isEmpty,
              let experience = experienceTextView.text, !experience.isEmpty else {
            showAlert(title: "Error", message: "All fields are required!")
            return
        }
        
        uploadButton.isEnabled = false
        activityIndicator.startAnimating()
        
        uploadImages { imageURLs in
            let postData: [String: Any] = [
                "city": city,
                "date": date,
                "experience": experience,
                "imageURLs": imageURLs,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            self.db.collection("myposts").addDocument(data: postData) { error in
                self.activityIndicator.stopAnimating()
                self.uploadButton.isEnabled = true
                
                if let error = error {
                    self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                } else {
                    self.showAlert(title: "Success", message: "Post uploaded successfully!")
                    self.clearFields()
                }
            }
        }
    }
    
    // MARK: - Image Upload to Firebase
    func uploadImages(completion: @escaping ([String]) -> Void) {
        var uploadedImageURLs: [String] = []
        let group = DispatchGroup()
        
        for image in selectedImages {
            group.enter()
            let imageName = UUID().uuidString
            let storageRef = storage.reference().child("post_images/\(imageName).jpg")
            
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                group.leave()
                continue
            }
            
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Upload Error: \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let url = url {
                        uploadedImageURLs.append(url.absoluteString)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(uploadedImageURLs)
        }
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = selectedImages[indexPath.item]
        cell.imageView.layer.cornerRadius = 8
        cell.imageView.layer.masksToBounds = true
        
        // Add a close button to remove the image
        cell.closeButton.tag = indexPath.item
        cell.closeButton.addTarget(self, action: #selector(removeImage(_:)), for: .touchUpInside)
        return cell
    }
    
    // MARK: - Remove Image
    @objc func removeImage(_ sender: UIButton) {
        let index = sender.tag
        selectedImages.remove(at: index)
    }
    
    // MARK: - Show Alerts
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Clear Fields
    func clearFields() {
        cityTextField.text = ""
        dateTextField.text = ""
        experienceTextView.text = "Write your experience..."
        experienceTextView.textColor = .lightGray
        selectedImages.removeAll()
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your experience..."
            textView.textColor = .lightGray
        }
    }
}

// Custom UICollectionView Cell
class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    let closeButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = .black.withAlphaComponent(0.6)
        closeButton.layer.cornerRadius = 10
        closeButton.frame = CGRect(x: bounds.width - 25, y: 5, width: 20, height: 20)
        addSubview(closeButton)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
