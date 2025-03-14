//
//  ViewController.swift
//  CustomTableView
//
//  Created by User@Param on 23/10/24.
//

import UIKit
import WebKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class NationalParkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    var selectedCity: String?
        var SafariData: [Safari] = []

        // ✅ No Data Label
        private let noDataLabel: UILabel = {
            let label = UILabel()
            label.text = "No Safari available in this region"
            label.textColor = .gray
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.isHidden = true // Initially hidden
            return label
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            table.delegate = self
            table.dataSource = self
            
            setupNoDataLabel() // Add No Data Label to the view

            if let city = UserDefaults.standard.string(forKey: "selectedCity") {
                selectedCity = city
                print("🏙️ NationalParkViewController Received City: \(city)")
                fetchSafariData(for: city)
            } else {
                print("❌ No selected city found in UserDefaults")
            }
        }

        private func setupNoDataLabel() {
            view.addSubview(noDataLabel)
            noDataLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }

        func fetchSafariData(for city: String) {
            print("🚀 Fetching Safari data for city: \(city)")

            let db = Firestore.firestore()
            db.collection("Safari").whereField("city", isEqualTo: city).getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Firestore error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No Safari places found for city: \(city)")
                    DispatchQueue.main.async {
                        self.SafariData = []
                        self.table.reloadData()
                        self.noDataLabel.isHidden = false // ✅ Show No Data Label
                    }
                    return
                }
                
                print("✅ Found \(documents.count) Safari places for city: \(city)")
                
                self.SafariData = documents.compactMap { doc in
                    let data = doc.data()
                    print("📌 Fetched Document: \(data)")
                    
                    return Safari(
                        title: data["title"] as? String ?? "No Title",
                        location: data["location"] as? String ?? "No Location",
                        bestTime: data["bestTime"] as? String ?? "Unknown bestTime",
                        cost: data["cost"] as? String ?? "Unknown Cost",
                        imageName: data["imageName"] as? String ?? "",
                        city: data["city"] as? String ?? city
                    )
                }
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                    self.noDataLabel.isHidden = !self.SafariData.isEmpty // ✅ Hide label if data exists
                    print("✅ Table Reloaded with \(self.SafariData.count) Items")
                }
            }
        }

        // MARK: - TableView Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("📌 TableView Number of Rows: \(SafariData.count)")
            return SafariData.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = table.dequeueReusableCell(withIdentifier: "ParamTableViewCell", for: indexPath) as? ParamTableViewCell else {
                print("❌ Failed to dequeue cell")
                return UITableViewCell()
            }

            let safari = SafariData[indexPath.row]
            cell.label11.text = safari.title
            cell.label12.text = safari.location
            cell.label13.text = "Best Time: \(safari.bestTime)"
            cell.label14.text = "Cost: \(safari.cost)"
            cell.iconImageView.layer.cornerRadius = 20

            print("✅ Setting up cell for: \(safari.title)")
            
            loadImage(from: safari.imageName, into: cell.iconImageView)

            return cell
        }

        // ✅ Load Image from Firestore Storage
        func loadImage(from gsURL: String, into imageView: UIImageView) {
            guard gsURL.hasPrefix("gs://") else {
                print("⚠️ Invalid GS URL format: \(gsURL)")
                return
            }

            let storageRef = Storage.storage().reference(forURL: gsURL)

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Error fetching download URL: \(error.localizedDescription)")
                    return
                }

                guard let url = url else {
                    print("❌ Failed to get a valid download URL")
                    return
                }

                print("✅ Firebase Image Download URL: \(url.absoluteString)")

                DispatchQueue.global(qos: .background).async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                            print("✅ Image Loaded Successfully")
                        }
                    } else {
                        print("❌ Failed to load image from URL")
                    }
                }
            }
        }
    }

    // ✅ Safari Data Model
    struct Safari {
        let title: String
        let location: String
        let bestTime: String
        let cost: String
        let imageName: String
        let city: String
    }
