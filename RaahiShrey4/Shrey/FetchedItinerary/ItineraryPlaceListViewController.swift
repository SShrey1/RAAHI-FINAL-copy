//
//  ItineraryPlaceListViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 13/03/2025.
//

import UIKit

class ItineraryPlaceListViewController: UIViewController {
    
    @IBOutlet weak var placeTableView: UITableView!
    
    var travelPlanName: String?
    var travelSpots: [TravelSpot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        title = travelPlanName ?? "Travel Spots"
    }
    
    private func setupTableView() {
        placeTableView.dataSource = self
        placeTableView.delegate = self
        placeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TravelSpotCell")
        placeTableView.rowHeight = 60
    }
}

// MARK: - UITableViewDataSource
extension ItineraryPlaceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return travelSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TravelSpotCell", for: indexPath)
        let travelSpot = travelSpots[indexPath.row]
        cell.textLabel?.text = travelSpot.name
        if let url = URL(string: travelSpot.imageURL) {
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
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ItineraryPlaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
