//
//  CulturalViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 21/08/1946 Saka.
//

import UIKit

class CulturalViewController: UIViewController {
    
    
    @IBOutlet weak var CulturalLabel: UILabel!
    
    @IBOutlet weak var CityLabel: UILabel!
    
    
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    
    @IBOutlet weak var insightsSearchBar: UISearchBar!
    
    @IBOutlet weak var insightsCollectionView: UICollectionView!
    
    @IBOutlet weak var createTripButton: UIButton!
    
    var searchedInsites : [Insite] = insites
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        if let layout = categoriesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
        
        insightsCollectionView.delegate = self
        insightsCollectionView.dataSource = self
        insightsCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        
        
        
       
        
        
    }
    
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchedInsites = insites
        } else {
            searchedInsites = insites.filter {
                insite in
                
                insite.title.lowercased().contains(searchText.lowercased())
            }
        }
         
         insightsCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedInsites = insites
        insightsSearchBar.text = ""
        insightsCollectionView.reloadData()
        
    }
}


extension CulturalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return selections.count
        } else {
            return insites.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollectionViewCell", for: indexPath) as! CategoriesCollectionViewCell
            cell.setup(with: selections[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightsCollectionViewCell", for: indexPath) as! InsightsCollectionViewCell
            cell.setup3(with: insites[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoriesCollectionView {
            return CGSize(width: 114, height: 100)
        }
        else {
            return CGSize(width: 175 , height: 226)
        }
    }
    
    
    
}


