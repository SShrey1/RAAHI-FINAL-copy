//
//  ViewController5.swift
//  CustomTableView
//
//  Created by User@Param on 01/11/24.
//

import UIKit
import WebKit
import FirebaseFirestore
import Firebase
import FirebaseStorage

class RaftingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table5: UITableView!
        
    var selectedCity: String?  // ✅ Store the selected city
        var trekData: [Trek] = []  // ✅ Store fetched Trekking data

        override func viewDidLoad() {
            super.viewDidLoad()
            table5.delegate = self
            table5.dataSource = self

            // ✅ Retrieve city from UserDefaults and fetch data
            if let city = UserDefaults.standard.string(forKey: "selectedCity") {
                selectedCity = city
                print("🏙️ RaftingViewController Received City: \(city)")
                fetchTrekkingData(for: city)
            } else {
                print("❌ No selected city found in UserDefaults")
            }
        }

        // ✅ Fetch Trekking data from Firestore based on the selected city
        func fetchTrekkingData(for city: String) {
            print("🚀 Fetching Trekking data for city: \(city)")

            let db = Firestore.firestore()
            db.collection("Trekking").whereField("city", isEqualTo: city).getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Firestore error: \(error.localizedDescription)")
                    return
                }

                // Check if we got documents
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No Trekking places found for city: \(city)")
                    DispatchQueue.main.async {
                        self.trekData = []
                        self.table5.reloadData()
                    }
                    return
                }

                print("✅ Found \(documents.count) Trekking places for city: \(city)")

                self.trekData = documents.compactMap { doc in
                    let data = doc.data()
                    print("📌 Fetched Document: \(data)")

                    return Trek(
                        title: data["title"] as? String ?? "No Title",
                        location: data["location"] as? String ?? "No Location",
                        duration: data["duration"] as? String ?? "Unknown Duration",
                        cost: data["cost"] as? String ?? "Unknown Cost",
                        imageName: data["imageName"] as? String ?? "",
                        city: data["city"] as? String ?? city
                    )
                }

                DispatchQueue.main.async {
                    self.table5.reloadData()
                    print("✅ Table Reloaded with \(self.trekData.count) Items")
                }
            }
        }

        // ✅ TableView Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("📌 TableView Number of Rows: \(trekData.count)")
            return trekData.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell4 = table5.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as? Custom4TableViewCell else {
                print("❌ Failed to dequeue cell")
                return UITableViewCell()
            }

            let trek = trekData[indexPath.row]
            cell4.labe31.text = trek.title
            cell4.label32.text = trek.location
            cell4.label33.text = "Duration: \(trek.duration)"
            cell4.label34.text = "Cost: \(trek.cost)"
            cell4.iconImageView.layer.cornerRadius = 20.0

            print("✅ Setting up cell for: \(trek.title)")

            // ✅ Load Image from Firestore Storage
            loadImage(from: trek.imageName, into: cell4.iconImageView)

            return cell4
        }

        // ✅ Load Image from Firestore Storage
    // ✅ Load Image from Firestore Storage
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

        @IBAction func Btn_URL5(_ sender: UIButton) {
            guard let url = URL(string: "https://himalayatrekker.com/tours/kashmir-great-lakes-trek/") else { return }

            let webVC = WebViewController5()
            webVC.urlToLoad = url
            present(webVC, animated: true, completion: nil)
        }
    }

    // ✅ Trek Data Model
    struct Trek {
        let title: String
        let location: String
        let duration: String
        let cost: String
        let imageName: String
        let city: String
    }
