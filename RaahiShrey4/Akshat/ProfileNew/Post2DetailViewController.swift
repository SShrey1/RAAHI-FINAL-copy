import UIKit
import FirebaseFirestore

class Post2DetailViewController: UIViewController {
    
    let post: Post
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let imageCarousel = UIScrollView()
    let pageControl = UIPageControl()
    let rightArrow = UIButton()  // Right arrow for carousel
    
    private var headerView: UIView?  // Reference to the header view
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        // Observe profile image updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileImageUpdate),
            name: NSNotification.Name("ProfileImageUpdated"),
            object: nil
        )
    }
    
    deinit {
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ProfileImageUpdated"), object: nil)
    }
    
    // MARK: - Handle Profile Image Update
    @objc private func handleProfileImageUpdate(notification: Notification) {
        if let imageData = notification.userInfo?["imageData"] as? Data,
           let profileImage = UIImage(data: imageData) {
            // Update the profile image in the header view
            if let headerView = self.headerView {
                if let profileImageView = headerView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                    profileImageView.image = profileImage
                }
            }
        }
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // Add scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Add contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Constraints for scrollView and contentView
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
        
        // Add header (profile picture, username, options button)
        let headerView = createHeaderView()
        contentView.addSubview(headerView)
        
        // Add image carousel
        setupImageCarousel()
        contentView.addSubview(imageCarousel)
        contentView.addSubview(pageControl)
        contentView.addSubview(rightArrow)
        
        // Add post details (city, date, experience)
        let detailsStackView = createDetailsStackView()
        contentView.addSubview(detailsStackView)
        
        // Constraints
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
        self.headerView = headerView  // Keep a reference
        
        // Profile picture
        let profileImageView = UIImageView()
        
        // Load profile image from UserDefaults
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let profileImage = UIImage(data: imageData) {
            profileImageView.image = profileImage
        } else {
            profileImageView.image = UIImage(named: "profile_placeholder")  // Default placeholder image
        }
        
        profileImageView.layer.cornerRadius = 15
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(profileImageView)
        
        // Username (fetched from UserDefaults)
        let usernameLabel = UILabel()
        if let savedName = UserDefaults.standard.string(forKey: "UserName") {
            usernameLabel.text = savedName
        } else {
            usernameLabel.text = "Username"  // Default value
        }
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 18)  // Increased font size
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(usernameLabel)
        
        // Options button (three dots)
        let optionsButton = UIButton(type: .system)
        optionsButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        optionsButton.tintColor = .black
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.addTarget(self, action: #selector(showDeleteOption), for: .touchUpInside)
        headerView.addSubview(optionsButton)
        
        // Constraints
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
        
        // Add images to carousel
        for (index, imageURL) in post.imageURLs.enumerated() {
            if let url = URL(string: imageURL) {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.loadImage1(from: url)  // Use the loadImage method
                imageView.frame = CGRect(x: CGFloat(index) * view.frame.width, y: 0, width: view.frame.width, height: 300)
                imageCarousel.addSubview(imageView)
            }
        }
        
        // Set content size
        imageCarousel.contentSize = CGSize(width: view.frame.width * CGFloat(post.imageURLs.count), height: 300)
        
        // Configure page control
        pageControl.numberOfPages = post.imageURLs.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure right arrow
        rightArrow.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightArrow.tintColor = .white
        rightArrow.backgroundColor = .black.withAlphaComponent(0.5)
        rightArrow.layer.cornerRadius = 15
        rightArrow.translatesAutoresizingMaskIntoConstraints = false
        rightArrow.addTarget(self, action: #selector(showNextImage), for: .touchUpInside)
        rightArrow.isHidden = post.imageURLs.count <= 1  // Hide if there's only one image
    }
    
    @objc private func showNextImage() {
        let nextPage = min(pageControl.currentPage + 1, post.imageURLs.count - 1)
        let offset = CGFloat(nextPage) * view.frame.width
        imageCarousel.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        pageControl.currentPage = nextPage
        rightArrow.isHidden = nextPage == post.imageURLs.count - 1  // Hide if on the last image
    }
    
    // MARK: - Details Stack View
    private func createDetailsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15  // Increased spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // City
        let cityLabel = UILabel()
        cityLabel.text = "📍 \(post.city)"
        cityLabel.font = UIFont.boldSystemFont(ofSize: 18)  // Increased font size
        stackView.addArrangedSubview(cityLabel)
        
        // Date
        let dateLabel = UILabel()
        dateLabel.text = "📅 \(post.date)"
        dateLabel.font = UIFont.systemFont(ofSize: 16)  // Increased font size
        stackView.addArrangedSubview(dateLabel)
        
        // Experience
        let experienceLabel = UILabel()
        experienceLabel.text = post.experience
        experienceLabel.font = UIFont.systemFont(ofSize: 16)  // Increased font size
        experienceLabel.numberOfLines = 0  // Allow multiple lines
        stackView.addArrangedSubview(experienceLabel)
        
        return stackView
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
        let db = Firestore.firestore()
        db.collection("myposts").document(post.id).delete { error in
            if let error = error {
                print("Error deleting post: \(error.localizedDescription)")
            } else {
                print("Post deleted successfully!")
                self.navigationController?.popViewController(animated: true)  // Go back to the previous screen
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
