////
////  ItineraryCollectionViewCell.swift
////  RaahiShrey4
////
////  Created by admin3 on 12/03/25.
////

//import UIKit
//
//class ItineraryCollectionViewCell: UICollectionViewCell {
//    
//    static let identifier = "ItineraryCollectionViewCell"
//    
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 10
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    private let nameLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 14)
//        label.textColor = .white
//        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        label.textAlignment = .center
//        label.layer.cornerRadius = 5
//        label.clipsToBounds = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.addSubview(imageView)
//        contentView.addSubview(nameLabel)
//        
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            
//            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
//            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
//            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
//            nameLabel.heightAnchor.constraint(equalToConstant: 25)
//        ])
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(with itinerary: Itinerary) {
//        nameLabel.text = itinerary.name
//        if let url = URL(string: itinerary.imageURL) {
//            loadImage(from: url)
//        }
//    }
//    
//    private func loadImage(from url: URL) {
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.imageView.image = image
//                }
//            }
//        }
//    }
//}
