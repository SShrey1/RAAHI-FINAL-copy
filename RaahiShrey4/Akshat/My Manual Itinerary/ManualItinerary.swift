import UIKit
import Firebase

struct Place {
    let id: String
    let name: String
    let city: String
    let imageURL: String
}

class ManualItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // Outlets from Storyboard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let db = Firestore.firestore()
        
        var places: [Place] = []
        var filteredPlaces: [Place] = []
        
        private var selectedCity: String? // Make it optional to handle no city case
        
        // MARK: - Init
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            setupUI()
            title = "Itinerary" // Static title
            
            // Check UserDefaults for an existing city
            if let savedCity = UserDefaults.standard.string(forKey: "selectedCity") {
                self.selectedCity = savedCity
                fetchPlaces(for: savedCity)
            } else {
                print("No city selected yet, table will be empty")
                // Optionally show an empty state UI
            }
            
            // Add observer for city updates
            NotificationCenter.default.addObserver(self, selector: #selector(cityUpdated), name: Notification.Name("CityUpdated"), object: nil)
        }
        
        deinit {
            // Remove observer to prevent memory leaks
            NotificationCenter.default.removeObserver(self, name: Notification.Name("CityUpdated"), object: nil)
        }
        
        // MARK: - Notification Handler
        @objc private func cityUpdated() {
            if let savedCity = UserDefaults.standard.string(forKey: "selectedCity") {
                self.selectedCity = savedCity
                fetchPlaces(for: savedCity)
            } else {
                print("No city selected in notification")
            }
        }
        
        // MARK: - Setup UI
        private func setupUI() {
            // Configure the search bar
            searchBar.delegate = self
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = .systemGray6
            searchBar.layer.cornerRadius = 10
            searchBar.layer.masksToBounds = true
            
            // Configure the table view
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
            tableView.rowHeight = 120 // Ensure consistent row height
            
            // Register programmatic cell
            tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        }
        
        // MARK: - Fetch Data
        func fetchPlaces(for city: String) {
            guard !city.isEmpty else {
                print("No city selected, skipping data fetch")
                return
            }
            
            db.collection("places").whereField("city", isEqualTo: city).getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching places: \(error.localizedDescription)")
                    return
                }
                
                self.places = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    return Place(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        city: data["city"] as? String ?? "",
                        imageURL: data["imageURL"] as? String ?? ""
                    )
                } ?? []
                
                self.filteredPlaces = self.places
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        // MARK: - Add to Itinerary
        func addToItinerary(_ place: Place) {
            let alert = UIAlertController(title: "Add to Itinerary", message: "Choose an option", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Create New Itinerary", style: .default, handler: { _ in
                self.createNewItinerary(for: place)
            }))
            
            alert.addAction(UIAlertAction(title: "Add to Existing Itinerary", style: .default, handler: { _ in
                self.addToExistingItinerary(place)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true)
        }
        
        func addToExistingItinerary(_ place: Place) {
            db.collection("itineraries").getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching itineraries: \(error)")
                    return
                }
                
                let itineraries = snapshot?.documents.compactMap { doc -> (String, String)? in
                    let data = doc.data()
                    guard let id = data["id"] as? String, let name = data["name"] as? String else { return nil }
                    return (id, name)
                } ?? []
                
                guard !itineraries.isEmpty else {
                    let noItinerariesAlert = UIAlertController(title: "No Itineraries", message: "You have no itineraries. Create one first!", preferredStyle: .alert)
                    noItinerariesAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(noItinerariesAlert, animated: true)
                    return
                }
                
                let chooseItineraryAlert = UIAlertController(title: "Select Itinerary", message: nil, preferredStyle: .actionSheet)
                
                for (id, name) in itineraries {
                    chooseItineraryAlert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                        self.addPlace(place, toItineraryWithID: id)
                    }))
                }
                
                chooseItineraryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(chooseItineraryAlert, animated: true)
            }
        }

        func addPlace(_ place: Place, toItineraryWithID itineraryID: String) {
            let itineraryRef = db.collection("itineraries").document(itineraryID)
            
            itineraryRef.updateData([
                "places": FieldValue.arrayUnion([place.id])
            ]) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("Error adding place to itinerary: \(error)")
                } else {
                    print("\(place.name) added to itinerary!")
                }
            }
        }
        
        func createNewItinerary(for place: Place) {
            let alert = UIAlertController(title: "New Itinerary", message: "Enter a name for your itinerary", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "E.g., Trip to Agra"
            }
            
            let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
                guard let self = self else { return }
                guard let itineraryName = alert.textFields?.first?.text, !itineraryName.isEmpty else { return }
                
                let itineraryID = UUID().uuidString
                let randomImageURL = "https://source.unsplash.com/300x200/?travel"

                let newItinerary = [
                    "id": itineraryID,
                    "name": itineraryName,
                    "imageURL": randomImageURL,
                    "places": [place.id],
                    "city": self.selectedCity ?? "Unknown" // Use optional or fallback
                ] as [String: Any]

                self.db.collection("itineraries").document(itineraryID).setData(newItinerary) { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error creating itinerary: \(error)")
                    } else {
                        print("Itinerary \(itineraryName) created!")
                    }
                }
            }
            
            alert.addAction(createAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true)
        }
        
        // MARK: - TableView Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredPlaces.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
            let place = filteredPlaces[indexPath.row]
            
            cell.configure(with: place)
            cell.addButtonAction = { [weak self] in
                self?.addToItinerary(place)
            }
            
            return cell
        }
        
        // MARK: - SearchBar Filtering
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            filteredPlaces = searchText.isEmpty ? places : places.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

//import UIKit
//import Firebase
//struct Place {
//    let id: String
//    let name: String
//    let city: String
//    let imageURL: String
//}
//
//class ManualItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
//    
//    private let tableView = UITableView()
//    private let searchBar = UISearchBar()
//    
//    let db = Firestore.firestore()
//    
//    var places: [Place] = []
//    var filteredPlaces: [Place] = []
//    
//    private var selectedCity: String
//
//    // MARK: - Init
//    init(city: String) {
//        self.selectedCity = city
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        setupUI()
//        fetchPlaces(for: selectedCity)
//    }
//   
//    // MARK: - Fetch Data
//    func fetchPlaces(for city: String) {
//        db.collection("places").whereField("city", isEqualTo: city).getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching places: \(error.localizedDescription)")
//                return
//            }
//            
//            self.places = snapshot?.documents.compactMap { doc in
//                let data = doc.data()
//                return Place(
//                    id: doc.documentID,
//                    name: data["name"] as? String ?? "",
//                    city: data["city"] as? String ?? "",
//                    imageURL: data["imageURL"] as? String ?? ""
//                )
//            } ?? []
//            
//            self.filteredPlaces = self.places
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//    
//    // MARK: - Add to Itinerary
//    func addToItinerary(_ place: Place) {
//        let alert = UIAlertController(title: "Add to Itinerary", message: "Choose an option", preferredStyle: .actionSheet)
//        
//        alert.addAction(UIAlertAction(title: "Create New Itinerary", style: .default, handler: { _ in
//            self.createNewItinerary(for: place)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Add to Existing Itinerary", style: .default, handler: { _ in
//            self.addToExistingItinerary(place)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//    func addToExistingItinerary(_ place: Place) {
//        db.collection("itineraries").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error fetching itineraries: \(error)")
//                return
//            }
//            
//            let itineraries = snapshot?.documents.compactMap { doc -> (String, String)? in
//                let data = doc.data()
//                guard let id = data["id"] as? String, let name = data["name"] as? String else { return nil }
//                return (id, name)
//            } ?? []
//            
//            guard !itineraries.isEmpty else {
//                let noItinerariesAlert = UIAlertController(title: "No Itineraries", message: "You have no itineraries. Create one first!", preferredStyle: .alert)
//                noItinerariesAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
//                self.present(noItinerariesAlert, animated: true)
//                return
//            }
//            
//            let chooseItineraryAlert = UIAlertController(title: "Select Itinerary", message: nil, preferredStyle: .actionSheet)
//            
//            for (id, name) in itineraries {
//                chooseItineraryAlert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
//                    self.addPlace(place, toItineraryWithID: id)
//                }))
//            }
//            
//            chooseItineraryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//            self.present(chooseItineraryAlert, animated: true)
//        }
//    }
//
//    func addPlace(_ place: Place, toItineraryWithID itineraryID: String) {
//        let itineraryRef = db.collection("itineraries").document(itineraryID)
//        
//        itineraryRef.updateData([
//            "places": FieldValue.arrayUnion([place.id])
//        ]) { error in
//            if let error = error {
//                print("Error adding place to itinerary: \(error)")
//            } else {
//                print("\(place.name) added to itinerary!")
//            }
//        }
//    }
//    
//    func createNewItinerary(for place: Place) {
//        let alert = UIAlertController(title: "New Itinerary", message: "Enter a name for your itinerary", preferredStyle: .alert)
//        
//        alert.addTextField { textField in
//            textField.placeholder = "E.g., Trip to Agra"
//        }
//        
//        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
//            guard let itineraryName = alert.textFields?.first?.text, !itineraryName.isEmpty else { return }
//            
//            let itineraryID = UUID().uuidString
//            let randomImageURL = "https://source.unsplash.com/300x200/?travel"
//
//            let newItinerary = [
//                "id": itineraryID,
//                "name": itineraryName,
//                "imageURL": randomImageURL,
//                "places": [place.id],
//                "city": self.selectedCity // Save the city with the itinerary
//            ] as [String: Any]
//
//            self.db.collection("itineraries").document(itineraryID).setData(newItinerary) { error in
//                if let error = error {
//                    print("Error creating itinerary: \(error)")
//                } else {
//                    print("Itinerary \(itineraryName) created!")
//                }
//            }
//        }
//        
//        alert.addAction(createAction)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//    
//    // MARK: - UI Setup
//    private func setupUI() {
//        searchBar.placeholder = "Search places..."
//        searchBar.delegate = self
//        searchBar.backgroundImage = UIImage()
//        searchBar.searchTextField.backgroundColor = .systemGray6
//        searchBar.layer.cornerRadius = 10
//        searchBar.layer.masksToBounds = true
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(searchBar)
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: "PlaceCell")
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.rowHeight = 120
//        tableView.separatorStyle = .none
//        tableView.backgroundColor = .clear
//        view.addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//
//    // MARK: - TableView Methods
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredPlaces.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
//        let place = filteredPlaces[indexPath.row]
//        
//        cell.configure(with: place)
//        
//        cell.addButtonAction = { [weak self] in
//            self?.addToItinerary(place)
//        }
//        
//        return cell
//    }
//    
//    // MARK: - SearchBar Filtering
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        filteredPlaces = searchText.isEmpty ? places : places.filter {
//            $0.name.lowercased().contains(searchText.lowercased())
//        }
//        
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }
//}
