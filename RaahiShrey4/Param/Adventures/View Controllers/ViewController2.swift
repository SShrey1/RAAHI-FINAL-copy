//
//  ViewController2.swift
//  CustomTableView
//
//  Created by User@Param on 29/10/24.
//

import UIKit
import WebKit
import FirebaseFirestore
import Firebase
import FirebaseStorage

class ViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table2: UITableView!
    
    private let noDataLabel: UILabel = {  // ✅ Label for "No Rafting Available"
            let label = UILabel()
            label.text = "Rafting is not available in this region"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            label.textColor = .gray
            label.isHidden = true  // Initially hidden
            return label
        }()
        
        var selectedCity: String?
        var RaftData: [Rafting] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            table2.dataSource = self
            table2.delegate = self
            
            setupNoDataLabel()
            
            if let city = UserDefaults.standard.string(forKey: "selectedCity") {
                selectedCity = city
                print("🏙️ RaftingViewController Received City: \(city)")
                fetchRaftingData(for: city)
            } else {
                print("❌ No selected city found in UserDefaults")
            }
        }
        
        // ✅ Add "No Data" Label to View
        private func setupNoDataLabel() {
            view.addSubview(noDataLabel)
            noDataLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        // ✅ Fetch Data from Firestore
        func fetchRaftingData(for city: String) {
            print("🚀 Fetching Rafting data for city: \(city)")

            let db = Firestore.firestore()
            db.collection("Rafting").whereField("city", isEqualTo: city).getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Firestore error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No Rafting places found for city: \(city)")
                    DispatchQueue.main.async {
                        self.RaftData = []
                        self.table2.reloadData()
                        self.noDataLabel.isHidden = false  // ✅ Show the message
                    }
                    return
                }

                print("✅ Found \(documents.count) Rafting places for city: \(city)")
                
                self.RaftData = documents.compactMap { doc in
                    let data = doc.data()
                    print("📌 Fetched Document: \(data)")

                    return Rafting(
                        title: data["title"] as? String ?? "No Title",
                        imageName: data["imageName"] as? String ?? "",
                        location: data["location"] as? String ?? "No Location",
                        distance: data["distance"] as? String ?? "Unknown Distance",
                        cost: data["cost"] as? String ?? "Unknown Cost",
                        city: data["city"] as? String ?? city
                    )
                }

                DispatchQueue.main.async {
                    self.table2.reloadData()
                    self.noDataLabel.isHidden = !self.RaftData.isEmpty  // ✅ Hide label if data is available
                }
            }
        }
        
        // ✅ TableView Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("📌 TableView Number of Rows: \(RaftData.count)")
            return RaftData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell1 = table2.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as? ParamTableViewCell else {
                print("❌ Failed to dequeue cell")
                return UITableViewCell()
            }
            
            let rafting = RaftData[indexPath.row]
            
            cell1.label11.text = rafting.title
            cell1.label12.text = rafting.location
            cell1.label13.text = rafting.distance
            cell1.label14.text = rafting.cost
            cell1.iconImageView.layer.cornerRadius = 20.0
            
            loadImage(from: rafting.imageName, into: cell1.iconImageView)
            
            return cell1
        }
        
        // ✅ Load Image from Firebase Storage
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
        
        @IBAction func Btn_URL2(_ sender: UIButton) {
            guard let url = URL(string: "https://www.holidify.com/pages/river-rafting-in-india-88.html") else { return }
            
            let webVC = WebViewController2()
            webVC.urlToLoad = url
            present(webVC, animated: true, completion: nil)
        }
    }

    // ✅ Rafting Data Model
    struct Rafting {
        let title: String
        let imageName: String
        let location: String
        let distance: String
        let cost: String
        let city: String
    }
