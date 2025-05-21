//
//  ViewController4.swift
//  CustomTableView
//
//  Created by User@Param on 01/11/24.
//

import UIKit
import WebKit
import FirebaseFirestore
import Firebase
import FirebaseStorage

class ViewController4: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table4: UITableView!
    
    private let noDataLabel: UILabel = {  // ✅ Label for "No Bungee Available"
            let label = UILabel()
            label.text = "Bungee Jumping is not available in this region"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            label.textColor = .gray
            label.isHidden = true  // Initially hidden
            return label
        }()
        
        var selectedCity: String?
        var BungeeData: [Bungee] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            table4.dataSource = self
            table4.delegate = self
            
            setupNoDataLabel()  // ✅ Add "No Data" Label
            
            if let city = UserDefaults.standard.string(forKey: "selectedCity") {
                selectedCity = city
                print("🏙️ ViewController4 Received City: \(city)")
                fetchBungeeData(for: city)
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
        
        func fetchBungeeData(for city: String) {
            print("🚀 Fetching Bungee data for city: \(city)")

            let db = Firestore.firestore()
            db.collection("Bungee").whereField("city", isEqualTo: city).getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Firestore error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No Bungee places found for city: \(city)")
                    DispatchQueue.main.async {
                        self.BungeeData = []
                        self.table4.reloadData()
                        self.noDataLabel.isHidden = false  // ✅ Show the message
                    }
                    return
                }

                print("✅ Found \(documents.count) Bungee places for city: \(city)")

                self.BungeeData = documents.compactMap { doc in
                    let data = doc.data()
                    print("📌 Fetched Document: \(data)")

                    return Bungee(
                        title: data["title"] as? String ?? "No Title",
                        imageName: data["imageName"] as? String ?? "",
                        location: data["location"] as? String ?? "No Location",
                        Height: data["Height"] as? String ?? "Unknown Height",
                        cost: data["cost"] as? String ?? "Unknown Cost",
                        city: data["city"] as? String ?? city
                    )
                }

                DispatchQueue.main.async {
                    self.table4.reloadData()
                    self.noDataLabel.isHidden = !self.BungeeData.isEmpty  // ✅ Hide label if data is available
                }
            }
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("📌 TableView Number of Rows: \(BungeeData.count)")
            return BungeeData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell3 = table4.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as? Custom3TableViewCell else {
                print("❌ Failed to dequeue cell")
                return UITableViewCell()
            }
            
            let bungee = BungeeData[indexPath.row]
            cell3.label21.text = bungee.title
            cell3.label22.text = bungee.location
            cell3.label23.text = "Height: \(bungee.Height)"
            cell3.label24.text = bungee.cost
            cell3.iconImageView.layer.cornerRadius = 20.0
            
            print("✅ Setting up cell for: \(bungee.title)")
            
            loadImage(from: bungee.imageName, into: cell3.iconImageView)
            return cell3
        }
        
        func loadImage(from gsURL: String, into imageView: UIImageView) {
            guard gsURL.hasPrefix("gs://") else {
                print("⚠️ Invalid GS URL format: \(gsURL)")
                return
            }
            
            let storageRef = Storage.storage().reference(forURL: gsURL)
            
            // ✅ Fetch the Downloadable URL
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
                
                // ✅ Load Image from URL
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
        
        @IBAction func Btn_URL4(_ sender: UIButton) {
            guard let url = URL(string: "https://www.holidify.com/collections/bungee-jumping-in-india") else { return }
            
            let webVC = WebViewController4()
            webVC.urlToLoad = url
            present(webVC, animated: true, completion: nil)
        }
    }

    // ✅ Bungee Data Model
    struct Bungee {
        let title: String
        let imageName: String
        let location: String
        let Height: String
        let cost: String
        let city: String
    }
