//
//  CulturalViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 21/08/1946 Saka.
//

import UIKit
import Firebase
import Kingfisher

class CulturalViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var CulturalLabel: UILabel!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var adventureImage: UIImageView!
    @IBOutlet weak var advenLabel: UILabel!
    @IBOutlet weak var monImage: UIImageView!
    @IBOutlet weak var monLabel: UILabel!
    @IBOutlet weak var beachImage: UIImageView!
    @IBOutlet weak var beachesLabel: UILabel!
    @IBOutlet weak var shrineaImage: UIImageView!
    @IBOutlet weak var shrinesLabel: UILabel!
    
  //  @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var insightsSearchBar: UISearchBar!
    
    @IBOutlet weak var insightsCollectionView: UICollectionView!
    
//    @IBOutlet weak var createTripButton: UIButton!
    
    var searchedInsites: [Insite] = []
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            loadInsights()
        }
        
    private func loadInsights() {
            if let selectedCity = UserDefaults.standard.string(forKey: "selectedCity") {
                CityLabel.text = selectedCity
                fetchInsights(for: selectedCity)
            } else {
                CityLabel.text = "Select a city first"
                searchedInsites = []
                insightsCollectionView.reloadData()
            }
        }

        
    private func fetchInsights(for city: String) {
            searchedInsites = insites.filter { $0.city == city }
            insightsCollectionView.reloadData()
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            
            insightsCollectionView.delegate = self
            insightsCollectionView.dataSource = self
            insightsCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
            
            insightsSearchBar.delegate = self
            setupImageTapGestures()
        }
        
        func setupImageTapGestures() {
            let adventureTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterByAdventure))
            adventureImage.isUserInteractionEnabled = true
            adventureImage.addGestureRecognizer(adventureTapGesture)
            
            let monumentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterByMonuments))
            monImage.isUserInteractionEnabled = true
            monImage.addGestureRecognizer(monumentsTapGesture)
            
            let beachesTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterByBeaches))
            beachImage.isUserInteractionEnabled = true
            beachImage.addGestureRecognizer(beachesTapGesture)
            
            let shrinesTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterByShrines))
            shrineaImage.isUserInteractionEnabled = true
            shrineaImage.addGestureRecognizer(shrinesTapGesture)
        }
        
        @objc func filterByAdventure() {
            filterCollectionView(by: "Adventure")
        }
        
        @objc func filterByMonuments() {
            filterCollectionView(by: "Monuments")
        }
        
        @objc func filterByBeaches() {
            filterCollectionView(by: "Beaches")
        }
        
        @objc func filterByShrines() {
            filterCollectionView(by: "Shrines")
        }
        
        func filterCollectionView(by type: String) {
            searchedInsites = searchedInsites.filter { $0.type == type }
            insightsCollectionView.reloadData()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                loadInsights()
            } else {
                searchedInsites = searchedInsites.filter { $0.title.lowercased().contains(searchText.lowercased()) }
                insightsCollectionView.reloadData()
            }
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            loadInsights()
        }
    }

    // MARK: - UICollectionView Delegates
    extension CulturalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return searchedInsites.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightsCollectionViewCell", for: indexPath) as! InsightsCollectionViewCell
            cell.setup3(with: searchedInsites[indexPath.row])
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 175, height: 226)
        }
    }
