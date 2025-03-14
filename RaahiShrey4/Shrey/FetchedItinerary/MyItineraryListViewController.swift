import UIKit
import Firebase

// Data Models
struct TravelPlan {
    let id: String
    let name: String
    let city: String
    let imageURL: String
    let placeIDs: [String]
}

struct TravelSpot {
    let id: String
    let name: String
    let city: String
    let imageURL: String
}

class MyItineraryListViewController: UIViewController {
    
    @IBOutlet weak var itineraryTableView: UITableView!
    
    let db = Firestore.firestore()
    var travelPlans: [TravelPlan] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchTravelPlans()
        title = "My Itineraries"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTravelPlans() // Refresh data when the view appears
    }
    
    private func setupTableView() {
        itineraryTableView.dataSource = self
        itineraryTableView.delegate = self
        itineraryTableView.register(UINib(nibName: "ItineraryTableViewCell", bundle: nil), forCellReuseIdentifier: "ItineraryCell")
        itineraryTableView.rowHeight = 120
        itineraryTableView.separatorInset = .init(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Fetch TravelPlans from Firestore
    func fetchTravelPlans() {
        print("Starting to fetch travel plans...")
        db.collection("itineraries").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching travel plans: \(error.localizedDescription)")
                return
            }
            print("Snapshot documents count: \(snapshot?.documents.count ?? 0)")
            self.travelPlans = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                print("Document data: \(data)")
                guard let name = data["name"] as? String,
                      let city = data["city"] as? String,
                      let imageURL = data["imageURL"] as? String,
                      let placeIDs = data["places"] as? [String] else {
                    print("Failed to parse document: \(doc.documentID)")
                    return nil
                }
                let id = doc.documentID
                print("Fetched travel plan: id=\(id), name=\(name), city=\(city), imageURL=\(imageURL), placeIDs=\(placeIDs)")
                return TravelPlan(id: id, name: name, city: city, imageURL: imageURL, placeIDs: placeIDs)
            } ?? []
            DispatchQueue.main.async {
                print("Reloading table view with \(self.travelPlans.count) items")
                self.itineraryTableView.reloadData()
                self.updateEmptyState()
            }
        }
    }
    
    private func updateEmptyState() {
        if travelPlans.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No travel plans available"
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
extension MyItineraryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows: \(travelPlans.count)")
        return travelPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItineraryCell", for: indexPath) as! ItineraryTableViewCell
        let travelPlan = travelPlans[indexPath.row]
        print("Configuring cell for travel plan: \(travelPlan.name) at row \(indexPath.row)")
        
        // Set the first image from the travel plan
        if let firstPlaceID = travelPlan.placeIDs.first {
            db.collection("places").document(firstPlaceID).getDocument { (snapshot, error) in
                if let error = error {
                    print("Error fetching first travel spot image: \(error.localizedDescription)")
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
        
        // Set the travel plan title
        cell.itineraryTitleLabel.text = travelPlan.name
        
        // Set the city in small text
        cell.itineraryTypeLabel.text = travelPlan.city
        cell.itineraryTypeLabel.font = .systemFont(ofSize: 12)
        
        // Hide or clear other labels
        cell.itineraryStatusLabel.text = nil
        
        // Set arrow image
        cell.arrowImageView.image = UIImage(systemName: "chevron.right")
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyItineraryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTravelPlan = travelPlans[indexPath.row]
        showTravelSpotList(for: selectedTravelPlan)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Show TravelSpot List
extension MyItineraryListViewController {
    func showTravelSpotList(for travelPlan: TravelPlan) {
        let placeIDs = travelPlan.placeIDs
        var travelSpots: [TravelSpot] = []
        
        let dispatchGroup = DispatchGroup()
        
        for placeID in placeIDs {
            dispatchGroup.enter()
            db.collection("places").document(placeID).getDocument { (snapshot, error) in
                defer { dispatchGroup.leave() }
                if let error = error {
                    print("Error fetching travel spot \(placeID): \(error.localizedDescription)")
                    return
                }
                if let data = snapshot?.data(),
                   let name = data["name"] as? String,
                   let city = data["city"] as? String,
                   let imageURL = data["imageURL"] as? String {
                    let travelSpot = TravelSpot(id: placeID, name: name, city: city, imageURL: imageURL)
                    travelSpots.append(travelSpot)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            let travelSpotListVC = ItineraryPlaceListViewController()
            travelSpotListVC.travelPlanName = travelPlan.name
            travelSpotListVC.travelSpots = travelSpots
            self.navigationController?.pushViewController(travelSpotListVC, animated: true)
        }
    }
}
