//
//  NewListViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 03/02/2025.
//

import UIKit
import Firebase
import FirebaseFirestore

// Protocol to send selected city back
protocol CitySelectionDelegate: AnyObject {
    func didSelectCity(_ city: String)
}

class NewListViewController: UIViewController {
    
    @IBOutlet weak var citySearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    

    let firebaseManager = FirestoreHelper.shared
        var stateLists: [StateList] = []  // Full city list from Firestore
        var filteredStateLists: [StateList] = []  // Filtered list for search results

        weak var delegate: CitySelectionDelegate?  // Add delegate property

        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.delegate = self
            tableView.dataSource = self
            citySearchBar.delegate = self  // Set search bar delegate

            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewListCell")
            
            fetchCitiesFromFirestore()
        }

        func fetchCitiesFromFirestore() {
            firebaseManager.fetchCities { result in
                switch result {
                case .success(let states):
                    self.stateLists = states
                    self.filteredStateLists = states  // Initially show all cities
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("❌ Error fetching cities: \(error.localizedDescription)")
                }
            }
        }
    }

    extension NewListViewController: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredStateLists.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewListCell", for: indexPath)
            cell.textLabel?.text = filteredStateLists[indexPath.row].title
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedCity = filteredStateLists[indexPath.row].title
            UserDefaults.standard.set(selectedCity, forKey: "selectedCity")
            
            // Post notification when a city is selected
            NotificationCenter.default.post(name: Notification.Name("CityUpdated"), object: nil)
            
            // Notify delegate
            delegate?.didSelectCity(selectedCity)

            // Go back to the previous screen after selecting a city
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - UISearchBar Delegate
    extension NewListViewController: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredStateLists = stateLists
            } else {
                filteredStateLists = stateLists.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            }
            tableView.reloadData()
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            filteredStateLists = stateLists
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
