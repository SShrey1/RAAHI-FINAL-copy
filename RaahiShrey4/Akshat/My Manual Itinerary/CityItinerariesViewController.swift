import UIKit
import Firebase

struct Itinerary2 {
    let id: String
    let name: String
    let imageURL: String
    let placeIDs: [String]
    let city: String  // Ensure this exists in your model
}

class CityItinerariesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 150)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ItineraryCardCell.self, forCellWithReuseIdentifier: "ItineraryCardCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let db = Firestore.firestore()
    var itineraries: [Itinerary] = []
    var selectedCity: String
    
    // MARK: - Init
    init(city: String) {
        self.selectedCity = city
        super.init(nibName: nil, bundle: nil)
    }
    
    // ✅ Add this initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fetchItineraries(for: selectedCity)
    }
    
    // MARK: - Fetch Itineraries
    func fetchItineraries(for city: String) {
        db.collection("itineraries").whereField("city", isEqualTo: city).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching itineraries: \(error.localizedDescription)")
                return
            }
            
            self.itineraries = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                return Itinerary2(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    imageURL: data["imageURL"] as? String ?? "",
                    placeIDs: data["places"] as? [String] ?? [],
                    city: data["city"] as? String ?? ""
                )
            } as! [Itinerary] 
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - CollectionView Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itineraries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItineraryCardCell", for: indexPath) as! ItineraryCardCell
        let itinerary = itineraries[indexPath.row]
        cell.configure(with: itinerary)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itinerary = itineraries[indexPath.row]
        let placesVC = ItineraryPlacesViewController(itinerary: itinerary)
        navigationController?.pushViewController(placesVC, animated: true)
    }
}

import UIKit

class ItineraryCardCell: UICollectionViewCell {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 10
        addSubview(imageView)
        addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with itinerary: Itinerary) {
        nameLabel.text = itinerary.name
        if let url = URL(string: itinerary.imageURL) {
            // Load image from URL (you can use a library like SDWebImage or Kingfisher for better performance)
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
