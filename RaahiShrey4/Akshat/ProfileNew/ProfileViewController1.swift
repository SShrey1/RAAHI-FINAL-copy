import UIKit
import FirebaseFirestore

struct Itinerary {
    var id: String
    var imageURL: String
    var name: String
    var places: [String]
}
var postCollectionVC: PostCollectionViewController?

extension ProfileViewController1: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedSegmentIndex == 0 ? 10 : itineraries.count // Example: 10 posts, or itinerary count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectedSegmentIndex == 0 {
            // Show Posts
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
            // Configure post cell
            return cell
        } else {
            // Show Itineraries
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItineraryCell", for: indexPath) as! ItineraryCell
            let itinerary = itineraries[indexPath.item]
            cell.configure(with: itinerary)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 2
        return CGSize(width: width, height: 20)
    }
}


class ProfileViewController1: UIViewController {
    
    let editProfileButton = UIButton()
    var selectedPlace: Place?  // Holds the selected place
    var selectedSegmentIndex: Int = 0  // Default segment (0 = My Posts, 1 = Itineraries)
    
    // Firebase Firestore reference
    let db = Firestore.firestore()
    
    // Stores fetched itineraries
    var itineraries: [Itinerary] = []
    
    @objc private func editProfileTapped() {
        let editProfileVC = EditProfileViewController()
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return button
    }()
    
    private let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "Image 11")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hannah Satan"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let editProfileLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Profile"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["My Posts", "Itineraries"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: "PostCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postCollectionVC = PostCollectionViewController()
                
                // Add it as a child view controller
                if let postCollectionVC = postCollectionVC {
                    addChild(postCollectionVC)
                    postCollectionVC.view.frame = collectionView.frame  // Match the frame of the collection view
                    view.addSubview(postCollectionVC.view)
                    postCollectionVC.didMove(toParent: self)
                }
        postCollectionVC?.view.isHidden = selectedSegmentIndex != 0
                collectionView.isHidden = selectedSegmentIndex == 0
        let yOffset = segmentedControl.frame.origin.y + segmentedControl.frame.height + 249  // Add some spacing
        postCollectionVC?.view.frame = CGRect(
                       x: 0,
                       y: yOffset,
                       width: view.frame.width,
                       height: view.frame.height - yOffset
                   )
        collectionView.register(ItineraryCell.self, forCellWithReuseIdentifier: "ItineraryCell")
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileName(_:)), name: NSNotification.Name("ProfileNameUpdated"), object: nil)

        // Observe profile name updates
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileName(_:)), name: NSNotification.Name("ProfileNameUpdated"), object: nil)

        // Load saved name from UserDefaults
        if let savedName = UserDefaults.standard.string(forKey: "UserName") {
            nameLabel.text = savedName
        }

        // Observe profile image updates
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage(_:)), name: NSNotification.Name("ProfileImageUpdated"), object: nil)

        // Load saved profile image from UserDefaults
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            profileImageView.image = savedImage
        }

        // Add tap gesture to "Edit Profile" label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editProfileLabelTapped))
        editProfileLabel.isUserInteractionEnabled = true
        editProfileLabel.addGestureRecognizer(tapGesture)

        // Add action to plus button
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        
        // Add action to segmented control to switch between My Posts and Itineraries
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)

        view.backgroundColor = .white
        setupViews()
        
        // Initial load of itineraries if "Itineraries" is selected by default
        if selectedSegmentIndex == 1 {
            loadItineraries()
        }
    }
    
    @objc private func updateProfileName(_ notification: Notification) {
        if let newName = notification.userInfo?["name"] as? String {
            nameLabel.text = newName
            // Save the new name in UserDefaults
            UserDefaults.standard.setValue(newName, forKey: "UserName")
        }
    }

    @objc private func updateProfileImage(_ notification: Notification) {
        if let userInfo = notification.userInfo, let image = userInfo["image"] as? UIImage {
            profileImageView.image = image
            // Save the image in UserDefaults
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "profileImage")
            }
        }
    }

//    deinit {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ProfileImageUpdated"), object: nil)
//    }
    
    @objc private func editProfileLabelTapped() {
        let editProfileVC = EditProfileViewController()
        navigationController?.pushViewController(editProfileVC, animated: true)
    }

    // Action when the upload button is tapped
    @objc private func uploadButtonTapped() {
        let uploadVC = UploadViewController()
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    // Show options to either create a new itinerary or add to an existing one
    private func showItineraryOptions(for place: Place) {
        let alert = UIAlertController(title: "Add to Itinerary", message: "Choose an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Create New Itinerary", style: .default, handler: { _ in
            self.createNewItinerary(for: place)
        }))
        
        alert.addAction(UIAlertAction(title: "Add to Existing Itinerary", style: .default, handler: { _ in
            self.addToExistingItinerary(place)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // Create a new itinerary
    private func createNewItinerary(for place: Place) {
        let alert = UIAlertController(title: "New Itinerary", message: "Enter a name for your itinerary", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "E.g., Trip to Agra"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let itineraryName = alert.textFields?.first?.text, !itineraryName.isEmpty else { return }
            
            // Create a unique itinerary ID
            let itineraryID = UUID().uuidString
            let randomImageURL = "https://source.unsplash.com/300x200/?travel"  // Placeholder image
            
            let newItinerary = Itinerary(id: itineraryID, imageURL: randomImageURL, name: itineraryName, places: [place.id])
            
            // Save the new itinerary to Firestore
            self.db.collection("itineraries").document(itineraryID).setData([
                "id": newItinerary.id,
                "name": newItinerary.name,
                "imageURL": newItinerary.imageURL,
                "places": newItinerary.places
            ]) { error in
                if let error = error {
                    print("Error creating itinerary: \(error)")
                } else {
                    print("Itinerary \(itineraryName) created!")
                    self.loadItineraries()  // Fetch updated itineraries
                }
            }
        }
        
        alert.addAction(createAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    
    // Add the selected place to an existing itinerary
    private func addToExistingItinerary(_ place: Place) {
        db.collection("itineraries").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching itineraries: \(error)")
                return
            }
            
            let itineraries = snapshot?.documents.compactMap { doc -> (String, String)? in
                let data = doc.data()
                guard let id = data["id"] as? String, let name = data["name"] as? String else { return nil }
                return (id, name)
            } ?? []
            
            if itineraries.isEmpty {
                let noItinerariesAlert = UIAlertController(title: "No Itineraries", message: "You have no itineraries. Create one first!", preferredStyle: .alert)
                noItinerariesAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(noItinerariesAlert, animated: true)
                return
            }
            
            let chooseItineraryAlert = UIAlertController(title: "Select Itinerary", message: nil, preferredStyle: .actionSheet)
            
            for (id, name) in itineraries {
                chooseItineraryAlert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                    self.addPlace(place, toItineraryWithID: id)
                }))
            }
            
            chooseItineraryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(chooseItineraryAlert, animated: true)
        }
    }
    
    private func addPlace(_ place: Place, toItineraryWithID itineraryID: String) {
        let itineraryRef = db.collection("itineraries").document(itineraryID)
        
        itineraryRef.updateData([
            "places": FieldValue.arrayUnion([place.id])
        ]) { error in
            if let error = error {
                print("Error adding place to itinerary: \(error)")
            } else {
                print("\(place.name) added to itinerary!")
                self.loadItineraries()  // Reload itineraries after addition
            }
        }
    }

    private func loadItineraries() {
        db.collection("itineraries").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading itineraries: \(error)")
                return
            }
            
            self.itineraries = snapshot?.documents.compactMap { doc -> Itinerary? in
                let data = doc.data()
                guard let id = data["id"] as? String,
                      let name = data["name"] as? String,
                      let imageURL = data["imageURL"] as? String,
                      let places = data["places"] as? [String] else { return nil }
                return Itinerary(id: id, imageURL: imageURL, name: name, places: places)
            } ?? []
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()  // Refresh collection view after fetching
            }
        }
    }


    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
         selectedSegmentIndex = sender.selectedSegmentIndex
         
         if selectedSegmentIndex == 0 {
             // Show Posts
             postCollectionVC?.view.isHidden = false
             collectionView.isHidden = true
             postCollectionVC?.fetchPosts()  // Fetch posts
         } else {
             // Show Itineraries
             postCollectionVC?.view.isHidden = true
             collectionView.isHidden = false
             loadItineraries()  // Fetch itineraries
         }
     }
     
     deinit {
         postCollectionVC?.willMove(toParent: nil)
         postCollectionVC?.view.removeFromSuperview()
         postCollectionVC?.removeFromParent()
     }
    
    private func setupViews() {
        view.addSubview(backButton)
        view.addSubview(uploadButton)
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(editProfileLabel)
        view.addSubview(segmentedControl)
        view.addSubview(collectionView)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        editProfileLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            uploadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            uploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            profileImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 5),
            
            editProfileLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            editProfileLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            
            segmentedControl.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
