
import UIKit
import FirebaseFirestore

class Post2DetailViewController: UIViewController {
    
    let post: Post
    let db = Firestore.firestore()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let imageCarousel = UIScrollView()
    let pageControl = UIPageControl()
    let rightArrow = UIButton()
    
    private var headerView: UIView?
    private var itineraryContainer: UIView?
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        if let itineraryID = post.itineraryID {
            fetchItinerary(itineraryID: itineraryID)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileImageUpdate),
            name: NSNotification.Name("ProfileImageUpdated"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ProfileImageUpdated"), object: nil)
    }
    
    @objc private func handleProfileImageUpdate(notification: Notification) {
        if let imageData = notification.userInfo?["imageData"] as? Data,
           let profileImage = UIImage(data: imageData),
           let headerView = self.headerView,
           let profileImageView = headerView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            profileImageView.image = profileImage
        }
    }
    
    // MARK: - Setup UI
    func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let headerView = createHeaderView()
        contentView.addSubview(headerView)
        
        setupImageCarousel()
        contentView.addSubview(imageCarousel)
        contentView.addSubview(pageControl)
        contentView.addSubview(rightArrow)
        
        let detailsStackView = createDetailsStackView()
        contentView.addSubview(detailsStackView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            imageCarousel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            imageCarousel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageCarousel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageCarousel.heightAnchor.constraint(equalToConstant: 300),
            
            pageControl.topAnchor.constraint(equalTo: imageCarousel.bottomAnchor, constant: 10),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            rightArrow.trailingAnchor.constraint(equalTo: imageCarousel.trailingAnchor, constant: -10),
            rightArrow.centerYAnchor.constraint(equalTo: imageCarousel.centerYAnchor),
            rightArrow.widthAnchor.constraint(equalToConstant: 30),
            rightArrow.heightAnchor.constraint(equalToConstant: 30),
            
            detailsStackView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Create Header View
    private func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView = headerView
        
        let profileImageView = UIImageView()
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let profileImage = UIImage(data: imageData) {
            profileImageView.image = profileImage
        } else {
            profileImageView.image = UIImage(named: "profile_placeholder")
        }
        profileImageView.layer.cornerRadius = 15
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(profileImageView)
        
        let usernameLabel = UILabel()
        usernameLabel.text = UserDefaults.standard.string(forKey: "UserName") ?? "Username"
        usernameLabel.font = .boldSystemFont(ofSize: 18)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(usernameLabel)
        
        let optionsButton = UIButton(type: .system)
        optionsButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        optionsButton.tintColor = .label
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.addTarget(self, action: #selector(showDeleteOption), for: .touchUpInside)
        headerView.addSubview(optionsButton)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            optionsButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            optionsButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    // MARK: - Image Carousel
    private func setupImageCarousel() {
        imageCarousel.translatesAutoresizingMaskIntoConstraints = false
        imageCarousel.isPagingEnabled = true
        imageCarousel.showsHorizontalScrollIndicator = false
        
        for (index, imageURL) in post.imageURLs.enumerated() {
            if let url = URL(string: imageURL) {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.loadImage1(from: url)
                imageView.frame = CGRect(x: CGFloat(index) * view.frame.width, y: 0, width: view.frame.width, height: 300)
                imageCarousel.addSubview(imageView)
            }
        }
        
        imageCarousel.contentSize = CGSize(width: view.frame.width * CGFloat(post.imageURLs.count), height: 300)
        
        pageControl.numberOfPages = post.imageURLs.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        rightArrow.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightArrow.tintColor = .white
        rightArrow.backgroundColor = .black.withAlphaComponent(0.5)
        rightArrow.layer.cornerRadius = 15
        rightArrow.translatesAutoresizingMaskIntoConstraints = false
        rightArrow.addTarget(self, action: #selector(showNextImage), for: .touchUpInside)
        rightArrow.isHidden = post.imageURLs.count <= 1
    }
    
    @objc private func showNextImage() {
        let nextPage = min(pageControl.currentPage + 1, post.imageURLs.count - 1)
        let offset = CGFloat(nextPage) * view.frame.width
        imageCarousel.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        pageControl.currentPage = nextPage
        rightArrow.isHidden = nextPage == post.imageURLs.count - 1
    }
    
    // MARK: - Details Stack View
    private func createDetailsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let cityLabel = UILabel()
        cityLabel.text = "📍 \(post.city)"
        cityLabel.font = .boldSystemFont(ofSize: 18)
        stackView.addArrangedSubview(cityLabel)
        
        let dateLabel = UILabel()
        dateLabel.text = "📅 \(post.date)"
        dateLabel.font = .systemFont(ofSize: 16)
        stackView.addArrangedSubview(dateLabel)
        
        let experienceLabel = UILabel()
        experienceLabel.text = post.experience
        experienceLabel.font = .systemFont(ofSize: 16)
        experienceLabel.numberOfLines = 0
        stackView.addArrangedSubview(experienceLabel)
        
        return stackView
    }
    
    // MARK: - Fetch Itinerary
    private func fetchItinerary(itineraryID: String) {
        db.collection("itineraries").document(itineraryID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching itinerary: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let name = data["name"] as? String,
                  let itineraryImageURL = data["imageURL"] as? String,
                  let placeIDs = data["places"] as? [String] else { return }
            
            self.fetchPlacesForItinerary(name: name, itineraryImageURL: itineraryImageURL, placeIDs: placeIDs)
        }
    }
    
    // MARK: - Fetch Places for Itinerary
    private func fetchPlacesForItinerary(name: String, itineraryImageURL: String, placeIDs: [String]) {
        var places: [(name: String, imageURL: String)] = []
        let group = DispatchGroup()
        
        for placeID in placeIDs {
            group.enter()
            db.collection("places").document(placeID).getDocument { snapshot, error in
                if let data = snapshot?.data(),
                   let name = data["name"] as? String,
                   let imageURL = data["imageURL"] as? String {
                    places.append((name: name, imageURL: imageURL))
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.displayItinerary(name: name, itineraryImageURL: itineraryImageURL, places: places)
        }
    }
    
    // MARK: - Display Itinerary
    private func displayItinerary(name: String, itineraryImageURL: String, places: [(name: String, imageURL: String)]) {
        // Create container
        let itineraryContainer = UIView()
        itineraryContainer.backgroundColor = .white
        itineraryContainer.layer.cornerRadius = 12
        itineraryContainer.layer.shadowColor = UIColor.black.cgColor
        itineraryContainer.layer.shadowOpacity = 0.1
        itineraryContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        itineraryContainer.layer.shadowRadius = 4
        itineraryContainer.translatesAutoresizingMaskIntoConstraints = false
        self.itineraryContainer = itineraryContainer
        
        // Header
        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.spacing = 10
        headerStackView.alignment = .center
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let itineraryImageView = UIImageView()
        if let url = URL(string: itineraryImageURL) {
            itineraryImageView.loadImage1(from: url)
        }
        itineraryImageView.contentMode = .scaleAspectFill
        itineraryImageView.clipsToBounds = true
        itineraryImageView.layer.cornerRadius = 8
        itineraryImageView.translatesAutoresizingMaskIntoConstraints = false
        itineraryImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        itineraryImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let itineraryTitleLabel = UILabel()
        itineraryTitleLabel.text = "🗺️ \(name)"
        itineraryTitleLabel.font = .boldSystemFont(ofSize: 18)
        itineraryTitleLabel.textColor = .label
        itineraryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerStackView.addArrangedSubview(itineraryImageView)
        headerStackView.addArrangedSubview(itineraryTitleLabel)
        
        // Places Scroll View (Horizontal)
        let placesScrollView = UIScrollView()
        placesScrollView.translatesAutoresizingMaskIntoConstraints = false
        placesScrollView.showsHorizontalScrollIndicator = true
        
        let placesStackView = UIStackView()
        placesStackView.axis = .horizontal
        placesStackView.spacing = 15
        placesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, place) in places.enumerated() {
            let placeView = UIView()
            placeView.translatesAutoresizingMaskIntoConstraints = false
            
            let placeImageView = UIImageView()
            if let url = URL(string: place.imageURL) {
                placeImageView.loadImage1(from: url)
            }
            placeImageView.contentMode = .scaleAspectFill
            placeImageView.clipsToBounds = true
            placeImageView.layer.cornerRadius = 8
            placeImageView.translatesAutoresizingMaskIntoConstraints = false
            placeImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            placeImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            let placeLabel = UILabel()
            placeLabel.text = "\(index + 1). \(place.name)"
            placeLabel.font = .systemFont(ofSize: 16)
            placeLabel.textColor = .label
            placeLabel.numberOfLines = 2
            placeLabel.textAlignment = .center
            placeLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let placeStackView = UIStackView()
            placeStackView.axis = .vertical
            placeStackView.spacing = 5
            placeStackView.alignment = .center
            placeStackView.addArrangedSubview(placeImageView)
            placeStackView.addArrangedSubview(placeLabel)
            placeStackView.translatesAutoresizingMaskIntoConstraints = false
            
            placeView.addSubview(placeStackView)
            
            NSLayoutConstraint.activate([
                placeStackView.centerXAnchor.constraint(equalTo: placeView.centerXAnchor),
                placeStackView.centerYAnchor.constraint(equalTo: placeView.centerYAnchor),
                placeView.widthAnchor.constraint(equalToConstant: 100) // Fixed width for each place
            ])
            
            placesStackView.addArrangedSubview(placeView)
        }
        
        placesScrollView.addSubview(placesStackView)
        itineraryContainer.addSubview(headerStackView)
        itineraryContainer.addSubview(placesScrollView)
        
        // Add to content view
        contentView.addSubview(itineraryContainer)
        
        // Constraints
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: itineraryContainer.topAnchor, constant: 15),
            headerStackView.leadingAnchor.constraint(equalTo: itineraryContainer.leadingAnchor, constant: 15),
            headerStackView.trailingAnchor.constraint(equalTo: itineraryContainer.trailingAnchor, constant: -15),
            
            placesScrollView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 10),
            placesScrollView.leadingAnchor.constraint(equalTo: itineraryContainer.leadingAnchor, constant: 15),
            placesScrollView.trailingAnchor.constraint(equalTo: itineraryContainer.trailingAnchor, constant: -15),
            placesScrollView.bottomAnchor.constraint(equalTo: itineraryContainer.bottomAnchor, constant: -15),
            placesScrollView.heightAnchor.constraint(equalToConstant: 120), // Adjusted height
            
            placesStackView.topAnchor.constraint(equalTo: placesScrollView.topAnchor),
            placesStackView.leadingAnchor.constraint(equalTo: placesScrollView.leadingAnchor),
            placesStackView.trailingAnchor.constraint(equalTo: placesScrollView.trailingAnchor),
            placesStackView.bottomAnchor.constraint(equalTo: placesScrollView.bottomAnchor),
            placesStackView.heightAnchor.constraint(equalTo: placesScrollView.heightAnchor)
        ])
        
        // Adjust content view constraints
        if let detailsStackView = contentView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            if let bottomConstraint = contentView.constraints.first(where: { $0.firstItem === detailsStackView && $0.firstAttribute == .bottom }) {
                contentView.removeConstraint(bottomConstraint)
            }
            
            NSLayoutConstraint.activate([
                itineraryContainer.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 20),
                itineraryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                itineraryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                itineraryContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                
                detailsStackView.bottomAnchor.constraint(equalTo: itineraryContainer.topAnchor, constant: -20)
            ])
        }
        
        // Ensure scroll view content size is updated
        scrollView.contentSize = contentView.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
    }
    
    // MARK: - Delete Post Option
    @objc private func showDeleteOption() {
        let alert = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deletePost()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func deletePost() {
        db.collection("myposts").document(post.id).delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post deleted successfully!")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - UIImageView Extension
extension UIImageView {
    func loadImage1(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}
