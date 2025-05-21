//
//  ItineraryDetailsViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 12/03/2025.
//

import UIKit

class ItineraryDetailsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var destinations: [Destination]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        title = "Itinerary Details"
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DestinationCell")
        tableView.rowHeight = 60
    }
}

// MARK: - UITableViewDataSource
extension ItineraryDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return destinations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationCell", for: indexPath)
        if let destination = destinations?[indexPath.row] {
            cell.textLabel?.text = destination.name
            // Optional: Load image if needed
            if let url = URL(string: destination.imageURL) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.imageView?.image = image
                            cell.imageView?.contentMode = .scaleAspectFill
                            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                            cell.imageView?.layer.cornerRadius = 5
                            cell.imageView?.clipsToBounds = true
                            cell.setNeedsLayout()
                        }
                    }
                }.resume()
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ItineraryDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
