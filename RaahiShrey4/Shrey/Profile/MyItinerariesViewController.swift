import UIKit
import Firebase

class MyItinerariesViewController: UIViewController {
    
    @IBOutlet weak var itineraryTableView: UITableView!
    
    let db = Firestore.firestore()
    var itineraryCards: [ItineraryCard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchItineraryCards()
        title = "My Itineraries" // Set a title for navigation
    }
    
    private func setupTableView() {
        itineraryTableView.dataSource = self
        itineraryTableView.delegate = self
        itineraryTableView.register(UINib(nibName: "ItineraryTableViewCell", bundle: nil), forCellReuseIdentifier: "ItineraryCell")
        itineraryTableView.rowHeight = 120
        itineraryTableView.separatorInset = .init(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Fetch ItineraryCards from Firestore
    func fetchItineraryCards() {
        print("Starting to fetch itineraryCards...")
        db.collection("itineraries").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching itineraryCards: \(error.localizedDescription)")
                return
            }
            print("Snapshot documents count: \(snapshot?.documents.count ?? 0)")
            self.itineraryCards = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                print("Document data: \(data)")
                guard let name = data["name"] as? String,
                      let city = data["city"] as? String,
                      let imageURL = data["imageURL"] as? String,
                      let placesIDs = data["places"] as? [String] else {
                    print("Failed to parse document: \(doc.documentID)")
                    return nil
                }
                let id = doc.documentID
                print("Fetched itineraryCard: id=\(id), name=\(name), city=\(city), imageURL=\(imageURL), placesIDs=\(placesIDs)")
                return ItineraryCard(id: id, name: name, city: city, imageURL: imageURL, placesIDs: placesIDs)
            } ?? []
            DispatchQueue.main.async {
                print("Reloading table view with \(self.itineraryCards.count) items")
                self.itineraryTableView.reloadData()
                self.updateEmptyState()
            }
        }
    }
    
    private func updateEmptyState() {
        if itineraryCards.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No itineraries available"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .gray
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            itineraryTableView.backgroundView = emptyLabel
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: itineraryTableView.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: itineraryTableView.centerYAnchor)
            ])
        } else {
            itineraryTableView.backgroundView = nil
        }
    }
}

// MARK: - UITableViewDataSource
extension MyItinerariesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows: \(itineraryCards.count)")
        return itineraryCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItineraryCell", for: indexPath) as! ItineraryTableViewCell
        let itineraryCard = itineraryCards[indexPath.row]
        print("Configuring cell for itineraryCard: \(itineraryCard.name) at row \(indexPath.row)")
        
        // Set the first image from the itineraryCard
        if let firstPlaceID = itineraryCard.placesIDs.first {
            db.collection("places").document(firstPlaceID).getDocument { (snapshot, error) in
                if let error = error {
                    print("Error fetching first destination image: \(error.localizedDescription)")
                    return
                }
                if let data = snapshot?.data(),
                   let imageURL = data["imageURL"] as? String,
                   let url = URL(string: imageURL) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell.itineraryImageView.image = image
                            }
                        }
                    }.resume()
                }
            }
        }
        
        // Set the itineraryCard title
        cell.itineraryTitleLabel.text = itineraryCard.name
        
        // Set the city in small text
        cell.itineraryTypeLabel.text = itineraryCard.city
        cell.itineraryTypeLabel.font = .systemFont(ofSize: 12)
        
        // Hide or clear other labels
        cell.itineraryStatusLabel.text = nil
        
        // Set arrow image
        cell.arrowImageView.image = UIImage(systemName: "chevron.right")
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyItinerariesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItineraryCard = itineraryCards[indexPath.row]
        showItineraryDestinations(for: selectedItineraryCard)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Show Destinations
extension MyItinerariesViewController {
    func showItineraryDestinations(for itineraryCard: ItineraryCard) {
        let placeIDs = itineraryCard.placesIDs
        var destinations: [Destination] = []
        
        let dispatchGroup = DispatchGroup()
        
        for placeID in placeIDs {
            dispatchGroup.enter()
            db.collection("places").document(placeID).getDocument { (snapshot, error) in
                defer { dispatchGroup.leave() }
                if let error = error {
                    print("Error fetching destination \(placeID): \(error.localizedDescription)")
                    return
                }
                if let data = snapshot?.data(),
                   let name = data["name"] as? String,
                   let city = data["city"] as? String,
                   let imageURL = data["imageURL"] as? String {
                    let destination = Destination(id: placeID, name: name, city: city, imageURL: imageURL)
                    destinations.append(destination)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            let detailsVC = ItineraryDetailsViewController()
            detailsVC.destinations = destinations
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}

// MARK: - Data Models
struct ItineraryCard {
    let id: String
    let name: String
    let city: String
    let imageURL: String
    let placesIDs: [String]
}

struct Destination {
    let id: String
    let name: String
    let city: String
    let imageURL: String
}
