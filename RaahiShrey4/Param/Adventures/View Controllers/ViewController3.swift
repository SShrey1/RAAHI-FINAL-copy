//
//  ViewController3.swift
//  CustomTableView
//
//  Created by User@Param on 31/10/24.
//
import UIKit
import WebKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class ViewController3: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table3: UITableView!
    
    var selectedCity: String? // Store the selected city
       var DiveData: [Diving] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        table3.dataSource = self
        table3.delegate = self
        
        // ✅ Retrieve city from UserDefaults and fetch data
        if let city = UserDefaults.standard.string(forKey: "selectedCity") {
            selectedCity = city
            print("🏙️ RaftingViewController Received City: \(city)")
            fetchDivingData(for: city)
        } else {
            print("❌ No selected city found in UserDefaults")
        }
    }
    
    func fetchDivingData(for city: String) {
        print("🚀 Fetching Diving data for city: \(city)")

        let db = Firestore.firestore()
        db.collection("Sky Diving").whereField("city", isEqualTo: city).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Firestore error: \(error.localizedDescription)")
                return
            }

            // Check if we got documents
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("⚠️ No Diving places found for city: \(city)")
                DispatchQueue.main.async {
                    self.DiveData = []
                    self.table3.reloadData()
                }
                return
            }

            print("✅ Found \(documents.count) Diving places for city: \(city)")

            self.DiveData = documents.compactMap { doc in
                let data = doc.data()
                print("📌 Fetched Document: \(data)")

                return Diving(
                    title: data["title"] as? String ?? "No Title",
                    imageName: data["imageName"] as? String ?? "",
                    location: data["location"] as? String ?? "No Location",
                    Height: data["Height"] as? String ?? "Unknown Height",
                    cost: data["cost"] as? String ?? "Unknown Cost",
                    city: data["city"] as? String ?? city
                )
            }

            DispatchQueue.main.async {
                self.table3.reloadData()
                print("✅ Table Reloaded with \(self.DiveData.count) Items")
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DiveData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        guard let cell2 = table3.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as? Custom2TableViewCell else {
            print("❌ Failed to dequeue cell")
            return UITableViewCell()
        }
        let diving = DiveData[indexPath.row]
        cell2.label2.text = diving.title
        cell2.label4.text = diving.location
        cell2.label6.text = "Height: \(diving.Height)"
        cell2.label8.text = "Cost: \(diving.cost)"
        cell2.iconImageView.layer.cornerRadius = 20.0
        
        print("✅ Setting up cell for: \(diving.title)")
        
        loadImage(from: diving.imageName, into: cell2.iconImageView)
        
        return cell2
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
    

    

    @IBAction func Btn_URL3(_ sender: UIButton) {
        guard let url = URL(string: "https://www.holidify.com/pages/skydiving-in-india-379.html") else { return }

        // Create the WebViewController instance
        let webVC = WebViewController()
        webVC.urlToLoad = url

        // Embed in a navigation controller for the "Done" button
        let navController = UINavigationController(rootViewController: webVC)
        self.present(navController, animated: true, completion: nil)
    }
}

struct Diving {
    let title: String
    let imageName: String
    let location: String
    let Height: String
    let cost: String
    let city : String
    
}
