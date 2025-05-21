import UIKit
import SDWebImage

class PlaceTableViewCell: UITableViewCell {
    
    private let placeImageView = UIImageView()
    private let nameLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let containerView = UIView() // Wrapper for better shadow handling
    var addButtonAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Container View for Rounded Corners & Shadows
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Place Image View
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        placeImageView.layer.cornerRadius = 12
        placeImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        placeImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(placeImageView)
        
        // Name Label
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        // Add Button
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = .systemBlue
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        containerView.addSubview(addButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Container View Constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Image View
            placeImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            placeImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            placeImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            placeImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.35),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: addButton.leadingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Add Button
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            addButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func didTapAddButton() {
        addButtonAction?() // Ensure this is called when tapped
    }
    
    func configure(with place: Place) {
        nameLabel.text = place.name
        if let url = URL(string: place.imageURL) {
            placeImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"), options: .retryFailed, completed: nil)
        } else {
            placeImageView.image = UIImage(named: "placeholder")
            print("Invalid URL for image: \(place.imageURL)")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 12).cgPath
    }
}
