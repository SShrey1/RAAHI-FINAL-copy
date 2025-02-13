//
//  NewListViewController.swift
//  RaahiShrey4
//
//  Created by user@59 on 03/02/2025.
//

import UIKit
import Firebase

class NewListViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    let firebaseManager = FirebaseManager.shared
    
    var states: [StateList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewListCell")
        
        states = JSONLoader.loadCities()
    }
}

extension NewListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewListCell", for: indexPath)
        cell.textLabel?.text = states[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = states[indexPath.row].title
        UserDefaults.standard.set(selectedCity, forKey: "selectedCity")
        print("City saved: \(selectedCity)")  // Debugging purpose
    }
}
