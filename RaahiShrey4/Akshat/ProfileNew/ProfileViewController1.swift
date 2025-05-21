import UIKit
import FirebaseFirestore
import FirebaseAuth

struct Itinerary {
    var id: String
    var imageURL: String
    var name: String
    var places: [String]
}

var postCollectionVC: PostCollectionViewController?

class ProfileViewController1: UIViewController {
    var selectedPlace: Place?
    var selectedSegmentIndex: Int = 0
    let db = Firestore.firestore()
    var itineraries: [Itinerary] = []
    
    private let backButton = UIButton(type: .system)
    private let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
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
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let editProfileLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Profile"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.isUserInteractionEnabled = true
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
        collectionView.register(ItineraryCell.self, forCellWithReuseIdentifier: "ItineraryCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postCollectionVC = PostCollectionViewController()
        
        if let postCollectionVC = postCollectionVC {
            addChild(postCollectionVC)
            postCollectionVC.view.frame = collectionView.frame
            view.addSubview(postCollectionVC.view)
            postCollectionVC.didMove(toParent: self)
        }
        
        postCollectionVC?.view.isHidden = selectedSegmentIndex != 0
        collectionView.isHidden = selectedSegmentIndex == 0
        
        let yOffset = segmentedControl.frame.origin.y + segmentedControl.frame.height + 249
        postCollectionVC?.view.frame = CGRect(x: 0, y: yOffset, width: view.frame.width, height: view.frame.height - yOffset)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileName(_:)), name: NSNotification.Name("ProfileNameUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage(_:)), name: NSNotification.Name("ProfileImageUpdated"), object: nil)
        
        if let savedName = UserDefaults.standard.string(forKey: "UserName") {
            nameLabel.text = savedName
        }
        
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"), let savedImage = UIImage(data: imageData) {
            profileImageView.image = savedImage
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editProfileLabelTapped))
        editProfileLabel.addGestureRecognizer(tapGesture)
        
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        
        view.backgroundColor = .white
        setupViews()
        fetchPosts() // Fetch posts on load
    }
    
    @objc private func updateProfileName(_ notification: Notification) {
        if let newName = notification.userInfo?["name"] as? String {
            nameLabel.text = newName
            UserDefaults.standard.set(newName, forKey: "UserName")
        }
    }
    
    @objc private func updateProfileImage(_ notification: Notification) {
        if let image = notification.userInfo?["image"] as? UIImage {
            profileImageView.image = image
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(imageData, forKey: "profileImage")
            }
        }
    }
    
    @objc private func editProfileLabelTapped() {
        let editProfileVC = EditProfileViewController()
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @objc private func uploadButtonTapped() {
        let uploadVC = UploadViewController()
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    // Fetch posts from Firestore and notify HomePageViewController
    private func fetchPosts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user found")
            return
        }
        
        db.collection("myposts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("❌ No posts found for user: \(userId)")
                    return
                }
                
                let posts = documents.compactMap { doc -> ListItem? in
                    let data = doc.data()
                    guard let city = data["city"] as? String,
                          let imageURLs = data["imageURLs"] as? [String],
                          let firstImage = imageURLs.first else { return nil }
                    return ListItem(title: city, image: firstImage, city: city)
                }
                
                print("✅ Fetched \(posts.count) posts from ProfileViewController1")
                
                // Notify HomePageViewController with fetched posts
                NotificationCenter.default.post(name: NSNotification.Name("UserPostsFetched"), object: nil, userInfo: ["posts": posts])
                
                // Update local UI if needed
                if self.selectedSegmentIndex == 0 {
                    postCollectionVC?.fetchPosts()
                }
            }
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        postCollectionVC?.view.isHidden = selectedSegmentIndex != 0
        collectionView.isHidden = selectedSegmentIndex == 0
        if selectedSegmentIndex == 1 {
            loadItineraries()
        } else {
            fetchPosts()
        }
    }
    
    private func loadItineraries() {
        db.collection("itineraries").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error loading itineraries: \(error)")
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
                self.collectionView.reloadData()
            }
        }
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
    
    deinit {
        postCollectionVC?.willMove(toParent: nil)
        postCollectionVC?.view.removeFromSuperview()
        postCollectionVC?.removeFromParent()
    }
}

extension ProfileViewController1: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedSegmentIndex == 0 ? 10 : itineraries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectedSegmentIndex == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItineraryCell", for: indexPath) as! ItineraryCell
            let itinerary = itineraries[indexPath.item]
            cell.configure(with: itinerary)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 2
        return CGSize(width: width, height: 200)
    }
}
