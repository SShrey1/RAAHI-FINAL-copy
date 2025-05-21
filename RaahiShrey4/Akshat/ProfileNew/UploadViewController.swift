import UIKit
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import FirebaseAuth

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PHPickerViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var selectedImages: [UIImage] = [] {
        didSet {
            imageCollectionView.reloadData()
            updateUILayout()
        }
    }
    
    var selectedItineraryID: String?
    var selectedItineraryName: String?
    
    // Scroll View
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true // Enable scrolling even with small content
        return scrollView
    }()
    
    // Content View inside Scroll View
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Enhanced Text Fields
    let cityTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter City",
            attributes: [.foregroundColor: UIColor.gray.withAlphaComponent(0.7)]
        )
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.font = .systemFont(ofSize: 16)
        return textField
    }()
    
    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Select Date",
            attributes: [.foregroundColor: UIColor.gray.withAlphaComponent(0.7)]
        )
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.font = .systemFont(ofSize: 16)
        return textField
    }()
    
    private lazy var datePickerPopup: UIView = {
        let popup = UIView()
        popup.backgroundColor = .white
        popup.layer.cornerRadius = 12
        popup.layer.borderWidth = 1
        popup.layer.borderColor = UIColor.systemGray5.cgColor
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 0.3
        popup.layer.shadowOffset = CGSize(width: 0, height: 2)
        popup.layer.shadowRadius = 6
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = .systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(dismissDatePicker), for: .touchUpInside)
        
        popup.addSubview(datePicker)
        popup.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: popup.topAnchor, constant: 15),
            datePicker.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 15),
            datePicker.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -15),
            
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 15),
            doneButton.centerXAnchor.constraint(equalTo: popup.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -15),
            doneButton.widthAnchor.constraint(equalToConstant: 100),
            doneButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return popup
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    let experienceTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Write your experience..."
        textView.textColor = .lightGray
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOpacity = 0.1
        textView.layer.shadowOffset = CGSize(width: 0, height: 2)
        textView.layer.shadowRadius = 4
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
        return textView
    }()
    
    let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Images", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 25)
        return button
    }()
    
    let addItineraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Itinerary", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        button.setTitleColor(.systemGreen, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 25)
        return button
    }()
    
    let itineraryLabel: UILabel = {
        let label = UILabel()
        label.text = "No Itinerary Selected"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.2
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 25)
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 120)
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
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var overlayView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "Create Post"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Set up scroll view hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(cityTextField)
        stackView.addArrangedSubview(dateTextField)
        stackView.addArrangedSubview(experienceTextView)
        stackView.addArrangedSubview(addImageButton)
        stackView.addArrangedSubview(addItineraryButton)
        stackView.addArrangedSubview(itineraryLabel)
        stackView.addArrangedSubview(uploadButton)
        stackView.addArrangedSubview(activityIndicator)
        
        // Constraints for scroll view and content view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // Ensure content width matches scroll view
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30), // Add bottom padding
            
            cityTextField.heightAnchor.constraint(equalToConstant: 50),
            dateTextField.heightAnchor.constraint(equalToConstant: 50),
            experienceTextView.heightAnchor.constraint(equalToConstant: 150),
            itineraryLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        experienceTextView.delegate = self
        cityTextField.delegate = self // Add delegate for cityTextField
        
        addImageButton.addTarget(self, action: #selector(selectImages), for: .touchUpInside)
        addItineraryButton.addTarget(self, action: #selector(selectItinerary), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadData), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        dateTextField.addGestureRecognizer(tap)
        dateTextField.isUserInteractionEnabled = true
        
        // Handle keyboard appearance
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Date Picker Methods
    @objc private func showDatePicker() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker)))
        view.addSubview(overlay)
        overlayView = overlay
        
        view.addSubview(datePickerPopup)
        NSLayoutConstraint.activate([
            datePickerPopup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePickerPopup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            datePickerPopup.widthAnchor.constraint(equalToConstant: 320),
            datePickerPopup.heightAnchor.constraint(equalToConstant: 420)
        ])
        
        datePickerPopup.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.datePickerPopup.transform = .identity
        })
    }
    
    @objc private func dismissDatePicker() {
        UIView.animate(withDuration: 0.3, animations: {
            self.datePickerPopup.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            self.datePickerPopup.removeFromSuperview()
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
        }
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formattedDate = dateFormatter.string(from: sender.date)
        dateTextField.text = formattedDate
    }
    
    // MARK: - Update UI Layout
    func updateUILayout() {
        if selectedImages.isEmpty {
            imageCollectionView.removeFromSuperview()
        } else {
            if imageCollectionView.superview == nil {
                stackView.insertArrangedSubview(imageCollectionView, at: 0)
                imageCollectionView.heightAnchor.constraint(equalToConstant: 130).isActive = true
            }
        }
        // Adjust content size after adding/removing collection view
        DispatchQueue.main.async {
            self.scrollView.contentSize = self.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
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
    
    // MARK: - Select Itinerary
    @objc func selectItinerary() {
        fetchItineraries { [weak self] itineraries in
            guard let self = self else { return }
            if itineraries.isEmpty {
                self.showAlert(title: "No Itineraries", message: "You have no saved itineraries yet.")
                return
            }
            
            let actionSheet = UIAlertController(title: "Select Itinerary", message: nil, preferredStyle: .actionSheet)
            for (id, name) in itineraries {
                actionSheet.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                    self.selectedItineraryID = id
                    self.selectedItineraryName = name
                    self.itineraryLabel.text = "Selected: \(name)"
                    self.itineraryLabel.textColor = .systemGreen
                }))
            }
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true)
        }
    }
    
    // Fetch itineraries from Firestore
    private func fetchItineraries(completion: @escaping ([(String, String)]) -> Void) {
        db.collection("itineraries").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching itineraries: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to fetch itineraries.")
                return
            }
            
            let itineraries = snapshot?.documents.compactMap { doc -> (String, String)? in
                let data = doc.data()
                guard let id = data["id"] as? String, let name = data["name"] as? String else { return nil }
                return (id, name)
            } ?? []
            
            completion(itineraries)
        }
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
    
//    // MARK: - Upload Data
//    @objc func uploadData() {
//        guard let city = cityTextField.text, !city.isEmpty,
//              let date = dateTextField.text, !date.isEmpty,
//              let experience = experienceTextView.text, !experience.isEmpty else {
//            showAlert(title: "Error", message: "All fields are required!")
//            return
//        }
//
//        uploadButton.isEnabled = false
//        activityIndicator.startAnimating()
//
//        uploadImages { [weak self] imageURLs in
//            guard let self = self else { return }
//            var postData: [String: Any] = [
//                "city": city.capitalized, // Ensure city is capitalized when uploading
//                "date": date,
//                "experience": experience,
//                "imageURLs": imageURLs,
//                "timestamp": FieldValue.serverTimestamp()
//            ]
//
//            if let itineraryID = self.selectedItineraryID {
//                postData["itineraryID"] = itineraryID
//            }
//
//            self.db.collection("myposts").addDocument(data: postData) { error in
//                self.activityIndicator.stopAnimating()
//                self.uploadButton.isEnabled = true
//
//                if let error = error {
//                    self.showAlert(title: "Upload Failed", message: error.localizedDescription)
//                } else {
//                    self.showAlert(title: "Success", message: "Post uploaded successfully!")
//                    self.clearFields()
//                }
//            }
//        }
//    }
    
    
    @objc func uploadData() {
        guard let city = cityTextField.text, !city.isEmpty,
              let date = dateTextField.text, !date.isEmpty,
              let experience = experienceTextView.text, !experience.isEmpty else {
            showAlert(title: "Error", message: "All fields are required!")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "You must be logged in to upload a post!")
            return
        }
        
        uploadButton.isEnabled = false
        activityIndicator.startAnimating()
        
        uploadImages { [weak self] imageURLs in
            guard let self = self else { return }
            var postData: [String: Any] = [
                "city": city.capitalized,
                "date": date,
                "experience": experience,
                "imageURLs": imageURLs,
                "timestamp": FieldValue.serverTimestamp(),
                "userId": userId // Add userId here
            ]
            
            if let itineraryID = self.selectedItineraryID {
                postData["itineraryID"] = itineraryID
            }
            
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
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
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
        selectedItineraryID = nil
        selectedItineraryName = nil
        itineraryLabel.text = "No Itinerary Selected"
        itineraryLabel.textColor = .gray
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cityTextField {
            // Get the current text and proposed new text
            guard let currentText = textField.text as NSString? else { return true }
            let newText = currentText.replacingCharacters(in: range, with: string)
            
            // Capitalize the first letter of each word, lowercase the rest
            textField.text = newText.capitalized
            
            // Return false to prevent the default text change (we handle it manually)
            return false
        }
        return true
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
