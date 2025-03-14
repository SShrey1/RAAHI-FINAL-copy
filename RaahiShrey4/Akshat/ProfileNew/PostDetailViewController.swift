//import UIKit
//
//class PostDetailViewController: UIViewController {
//    
//    // MARK: - Properties
//    var post: Post
//    
//    // UI Components
//    private let scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        return scrollView
//    }()
//    
//    private let contentView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 8
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    private let cityLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        label.textColor = .black
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let dateLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .darkGray
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let experienceLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        label.textColor = .black
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    // MARK: - Initializer
//    init(post: Post) {
//        self.post = post
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//        configureUI()
//    }
//    
//    // MARK: - Setup
//    private func setupViews() {
//        view.backgroundColor = .white
//        title = "Post Details"
//        
//        // Add scrollView and contentView
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        
//        // Add UI components to contentView
//        contentView.addSubview(imageView)
//        contentView.addSubview(cityLabel)
//        contentView.addSubview(dateLabel)
//        contentView.addSubview(experienceLabel)
//        
//        // Constraints
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            imageView.heightAnchor.constraint(equalToConstant: 200),
//            
//            cityLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
//            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            
//            dateLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 10),
//            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            
//            experienceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
//            experienceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            experienceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            experienceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
//        ])
//    }
//    
//    // MARK: - Configure UI
//    private func configureUI() {
//        // Set post data to UI components
//        cityLabel.text = "City: \(post.city)"
//        dateLabel.text = "Date: \(post.date)"
//        experienceLabel.text = "Experience: \(post.experience)"
//        
//        // Load the first image from the post's imageURLs
//        if let imageURL = post.imageURLs.first, let url = URL(string: imageURL) {
//            URLSession.shared.dataTask(with: url) { data, _, _ in
//                if let data = data, let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self.imageView.image = image
//                    }
//                }
//            }.resume()
//        }
//    }
//}
