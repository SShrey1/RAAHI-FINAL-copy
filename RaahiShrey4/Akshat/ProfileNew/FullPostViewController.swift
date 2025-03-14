//class FullPostViewController: UIViewController {
//    private let post: Post
//    
//    init(post: Post) {
//        self.post = post
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        setupViews()
//    }
//    
//    private func setupViews() {
//        let imageView = UIImageView()
//        let titleLabel = UILabel()
//        let descriptionLabel = UILabel()
//        
//        view.addSubview(imageView)
//        view.addSubview(titleLabel)
//        view.addSubview(descriptionLabel)
//        
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 8
//        
//        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        titleLabel.textAlignment = .center
//        
//        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        descriptionLabel.numberOfLines = 0
//        
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
//            
//            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
//            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//        ])
//        
//        if let url = URL(string: post.imageURL) {
//            URLSession.shared.dataTask(with: url) { data, response, error in
//                if let data = data, let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        imageView.image = image
//                    }
//                }
//            }.resume()
//        }
//        titleLabel.text = post.title
//        descriptionLabel.text = post.description
//    }
//}
