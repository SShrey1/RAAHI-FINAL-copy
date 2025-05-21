//
//  TripPlanDetailViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 13/03/2025.
//

import UIKit
import Firebase

class TripPlanDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private let db = Firestore.firestore()
    private let tripPlan: TripPlan
    private var places: [Place] = []
    private let imageCache = NSCache<NSString, UIImage>()
    
    init(tripPlan: TripPlan) {
        self.tripPlan = tripPlan
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = tripPlan.name
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchPlaces()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceDetailCell")
    }
    
    private func fetchPlaces() {
        let group = DispatchGroup()
        
        for placeId in tripPlan.placeIds {
            group.enter()
            db.collection("places").document(placeId).getDocument { [weak self] snapshot, error in
                guard let self = self, let data = snapshot?.data() else {
                    group.leave()
                    return
                }
                
                let place = Place(
                    id: placeId,
                    name: data["name"] as? String ?? "",
                    city: data["city"] as? String ?? "",
                    imageURL: data["imageURL"] as? String ?? ""
                )
                self.places.append(place)
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            self.imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailCell", for: indexPath)
        let place = places[indexPath.row]
        
        cell.selectionStyle = .none
        
        let imageView = UIImageView()
        let nameLabel = UILabel()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(imageView)
        cell.contentView.addSubview(nameLabel)
        
        nameLabel.text = place.name
        nameLabel.font = .systemFont(ofSize: 16)
        
        loadImage(from: place.imageURL) { image in
            imageView.image = image ?? UIImage(named: "placeholder")
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
            
            nameLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10)
        ])
        
        cell.contentView.backgroundColor = .systemGray6
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
