//
//  TripPlanCardViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 13/03/2025.
//

//import UIKit
//import Firebase
//
//struct TripPlan {
//    let id: String
//    let name: String
//    let city: String
//    let imageURL: String
//    let placeIds: [String]
//}
//
//class ItineraryPlaceCell: UITableViewCell {
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        textLabel?.font = .systemFont(ofSize: 16)
//        backgroundColor = .systemGray6
//        layer.cornerRadius = 8
//        layer.masksToBounds = true
//    }
//}
//
//class TripPlanCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    @IBOutlet weak var tableView: UITableView! // Add this outlet to connect in storyboard
//    
//    private let db = Firestore.firestore()
//    private var tripPlans: [TripPlan] = []
//    private var places: [String: Place] = [:]
//    var currentCity: String? // Optional property to receive city from HomePage
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "My Trip Plans"
//        view.backgroundColor = .systemBackground
//        setupTableView()
//        fetchTripPlans()
//    }
//    
//    private func setupTableView() {
//        // Since we're using storyboard, we'll configure this in IB, but we'll set delegates here
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TripPlanCardCell")
//        tableView.register(ItineraryPlaceCell.self, forCellReuseIdentifier: "ItineraryPlaceCell")
//    }
//    
//    private func fetchTripPlans() {
//        db.collection("itineraries").getDocuments { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error fetching trip plans: \(error)")
//                return
//            }
//            
//            self.tripPlans = snapshot?.documents.compactMap { doc in
//                let data = doc.data()
//                return TripPlan(
//                    id: data["id"] as? String ?? "",
//                    name: data["name"] as? String ?? "",
//                    city: data["city"] as? String ?? "",
//                    imageURL: data["imageURL"] as? String ?? "",
//                    placeIds: data["places"] as? [String] ?? []
//                )
//            } ?? []
//            
//            self.fetchAllPlaces()
//        }
//    }
//    
//    private func fetchAllPlaces() {
//        let allPlaceIds = Set(tripPlans.flatMap { $0.placeIds })
//        let group = DispatchGroup()
//        
//        for placeId in allPlaceIds {
//            group.enter()
//            db.collection("places").document(placeId).getDocument { [weak self] snapshot, error in
//                guard let self = self, let data = snapshot?.data() else {
//                    group.leave()
//                    return
//                }
//                
//                let place = Place(
//                    id: placeId,
//                    name: data["name"] as? String ?? "",
//                    city: data["city"] as? String ?? "",
//                    imageURL: data["imageURL"] as? String ?? ""
//                )
//                self.places[placeId] = place
//                group.leave()
//            }
//        }
//        
//        group.notify(queue: .main) { [weak self] in
//            self?.tableView.reloadData()
//        }
//    }
//    
//    // MARK: - TableView Methods
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return tripPlans.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tripPlans[section].placeIds.count + 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let tripPlan = tripPlans[indexPath.section]
//        
//        if indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlanCardCell", for: indexPath)
//            cell.selectionStyle = .none
//            
//            let imageView = UIImageView()
//            let titleLabel = UILabel()
//            let cityLabel = UILabel()
//            
//            imageView.translatesAutoresizingMaskIntoConstraints = false
//            titleLabel.translatesAutoresizingMaskIntoConstraints = false
//            cityLabel.translatesAutoresizingMaskIntoConstraints = false
//            
//            cell.contentView.addSubview(imageView)
//            cell.contentView.addSubview(titleLabel)
//            cell.contentView.addSubview(cityLabel)
//            
//            if let url = URL(string: tripPlan.imageURL) {
//                URLSession.shared.dataTask(with: url) { data, _, _ in
//                    if let data = data {
//                        DispatchQueue.main.async {
//                            imageView.image = UIImage(data: data)
//                        }
//                    }
//                }.resume()
//            }
//            
//            titleLabel.text = tripPlan.name
//            titleLabel.font = .boldSystemFont(ofSize: 18)
//            cityLabel.text = tripPlan.city
//            cityLabel.font = .systemFont(ofSize: 14)
//            cityLabel.textColor = .gray
//            
//            NSLayoutConstraint.activate([
//                imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
//                imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
//                imageView.widthAnchor.constraint(equalToConstant: 100),
//                imageView.heightAnchor.constraint(equalToConstant: 80),
//                
//                titleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
//                titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
//                titleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
//                
//                cityLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
//                cityLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
//                cityLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10)
//            ])
//            
//            cell.contentView.backgroundColor = .white
//            cell.contentView.layer.cornerRadius = 10
//            cell.contentView.layer.masksToBounds = true
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ItineraryPlaceCell", for: indexPath) as! ItineraryPlaceCell
//            let placeId = tripPlan.placeIds[indexPath.row - 1]
//            cell.textLabel?.text = places[placeId]?.name ?? "Unknown Place"
//            return cell
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return indexPath.row == 0 ? 100 : 50
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let spacer = UIView()
//        spacer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20)
//        return spacer
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 20
//    }
//}


import UIKit
import Firebase

struct TripPlan {
    let id: String
    let name: String
    let city: String
    let imageURL: String
    let placeIds: [String]
}

class TripPlanCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let db = Firestore.firestore()
    private var tripPlans: [TripPlan] = []
    private var placeImages: [String: String] = [:]
    private let imageCache = NSCache<NSString, UIImage>()
    var currentCity: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Trip Plans"
        view.backgroundColor = .systemGray6
        setupTableView()
        fetchTripPlans()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    private func setupTableView() {
        guard tableView != nil else {
            print("Error: tableView outlet is not connected")
            return
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TripPlanCardCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    private func fetchTripPlans() {
        var query: Query = db.collection("itineraries")
        if let city = currentCity, !city.isEmpty {
            query = query.whereField("city", isEqualTo: city)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching trip plans: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in itineraries collection")
                return
            }
            
            self.tripPlans = documents.compactMap { doc in
                let data = doc.data()
                return TripPlan(
                    id: data["id"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    city: data["city"] as? String ?? "",
                    imageURL: data["imageURL"] as? String ?? "",
                    placeIds: data["places"] as? [String] ?? []
                )
            }
            
            if self.tripPlans.isEmpty {
                print("No trip plans found for city: \(self.currentCity ?? "all cities")")
            }
            
            self.fetchFirstPlaceImages()
        }
    }
    
    private func fetchFirstPlaceImages() {
        let group = DispatchGroup()
        
        for tripPlan in tripPlans {
            guard let firstPlaceId = tripPlan.placeIds.first else {
                print("No places in trip plan: \(tripPlan.id)")
                continue
            }
            group.enter()
            db.collection("places").document(firstPlaceId).getDocument { [weak self] snapshot, error in
                guard let self = self else {
                    group.leave()
                    return
                }
                if let error = error {
                    print("Failed to fetch image for place \(firstPlaceId): \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                guard let data = snapshot?.data(),
                      let imageURL = data["imageURL"] as? String else {
                    print("No imageURL found for place: \(firstPlaceId)")
                    group.leave()
                    return
                }
                
                print("Fetched image URL for \(tripPlan.id): \(imageURL)")
                self.placeImages[tripPlan.id] = imageURL
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func loadImage(from urlString: String, for imageView: UIImageView, indexPath: IndexPath) {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            imageView.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {
            imageView.image = UIImage(named: "placeholder")
            print("Invalid URL: \(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "placeholder")
                }
                print("Error loading image from \(urlString): \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? UITableViewCell,
                   cell.tag == indexPath.row {
                    imageView.image = image
                }
            }
        }.resume()
    }
    
    // MARK: - Delete Functionality
    private func deleteTripPlan(at indexPath: IndexPath) {
        let tripPlan = tripPlans[indexPath.row]
        
        db.collection("itineraries").document(tripPlan.id).delete { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error deleting trip plan: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Failed to delete trip plan: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            self.tripPlans.remove(at: indexPath.row)
            self.placeImages.removeValue(forKey: tripPlan.id)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            print("Trip plan \(tripPlan.name) deleted successfully")
        }
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlanCardCell", for: indexPath)
        let tripPlan = tripPlans[indexPath.row]
        
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        
        // Card Container View
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Image View
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold) // Larger font size
        titleLabel.textColor = .white // White color
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // City Label
        let cityLabel = UILabel()
        cityLabel.font = .systemFont(ofSize: 20, weight: .medium) // Increased size
        cityLabel.textColor = .white // White for consistency
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Gradient Overlay
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        imageView.layer.addSublayer(gradientLayer)
        
        // Setup content
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(cardView)
        cardView.addSubview(imageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(cityLabel)
        
        titleLabel.text = tripPlan.name
        cityLabel.text = tripPlan.city
        
        let imageURL = placeImages[tripPlan.id] ?? tripPlan.imageURL
        loadImage(from: imageURL, for: imageView, indexPath: indexPath)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Card View Constraints
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -15),
            
            // Image View Constraints
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 180),
            
            // Title Label Constraints
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: cityLabel.topAnchor, constant: -5),
            
            // City Label Constraints
            cityLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            cityLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            cityLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -15)
        ])
        
        // Update gradient frame after layout
        DispatchQueue.main.async {
            gradientLayer.frame = imageView.bounds
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tripPlan = tripPlans[indexPath.row]
        let detailVC = TripPlanDetailViewController(tripPlan: tripPlan)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            let alert = UIAlertController(title: "Delete Trip Plan", message: "Are you sure you want to delete \(self.tripPlans[indexPath.row].name)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false)
            })
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.deleteTripPlan(at: indexPath)
                completion(true)
            })
            self.present(alert, animated: true)
        }
        
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
