import UIKit
import FirebaseFirestore

class ItinerariesViewController: UIViewController {

    private var itineraries: [String: [String]] = [:] // Dictionary with City -> Places
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        fetchItineraries()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItineraryCell.self, forCellReuseIdentifier: "ItineraryCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchItineraries() {
        let db = Firestore.firestore()
        db.collection("itineraries").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }

            for document in documents {
                let data = document.data()
                if let city = data["city"] as? String, let places = data["places"] as? [String] {
                    self.itineraries[city] = places
                }
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ItinerariesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return itineraries.keys.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(itineraries.keys)[section] // City name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let city = Array(itineraries.keys)[section]
        return itineraries[city]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Itinerary1Cell", for: indexPath) as! Itinerary1Cell
        let city = Array(itineraries.keys)[indexPath.section]
        let place = itineraries[city]?[indexPath.row] ?? ""
        cell.configure(with: place)
        return cell
    }
}
