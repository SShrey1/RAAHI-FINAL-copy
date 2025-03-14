//
//  FireStoreManager.swift
//  RaahiShrey4
//
//  Created by user@59 on 13/02/2025.
//

import UIKit
import Foundation
import FirebaseFirestore
import FirebaseStorage


struct StateList: Codable {
    let id: String
    let title: String
}

struct ListItem {
    let title: String
    let image: String
    let city : String

}

struct ListItem2 {
    let title: String
    let image: String
}

struct ListItem3 {
    let title: String
    let image: String
}

struct trendingzData {
    var image : String
    var about : String
    var title : String
}

class FirestoreHelper {
    static let shared = FirestoreHelper() // Singleton instance
    private let db = Firestore.firestore()
    
    func fetchTrendingItem(by title: String, completion: @escaping (trendingzData?) -> Void) {
            db.collection("FamousView")  // ✅ Firestore collection
                .whereField("title", isEqualTo: title) // ✅ Match title
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ Firestore Error: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    guard let document = snapshot?.documents.first else {
                        print("⚠️ No Trending item found for title: \(title)")
                        completion(nil)
                        return
                    }

                    let data = document.data()
                    guard let title = data["title"] as? String,
                          let image = data["image"] as? String,
                          let about = data["about"] as? String else {
                        print("⚠️ Missing data fields in Firestore for \(title)")
                        return
                    }

                    print("📄 Fetched Trending Item: \(title), Image: \(image), About: \(about)")
                    
                    completion(trendingzData(image: image, about: about, title: title))
                }
        }

    func fetchTrendingItems(for city: String, completion: @escaping ([ListItem]) -> Void) {
        db.collection("famous") // ✅ Collection where Trending data is stored
            .whereField("city", isEqualTo: city) // ✅ Filter by selected city
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Firestore Trending Fetch Error: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("❌ No Trending documents found in Firestore for city: \(city)")
                    completion([])
                    return
                }

                let items = documents.compactMap { doc -> ListItem? in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let imagePath = data["image"] as? String,
                          let city = data["city"] as? String else { return nil }

                    print("📄 Fetched Trending Item: \(title), Image: \(imagePath), City: \(city)")  // ✅ Debug log
                    
                    return ListItem(title: title, image: imagePath, city: city)
                }

                completion(items)
            }
    }

    
    
    // ✅ Fetch Adventure Data from Firestore
    func fetchAdventureItems(completion: @escaping ([ListItem2]) -> Void) {
        db.collection("adventure").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Firestore Adventure Fetch Error: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                print("❌ No adventure documents found in Firestore.")
                completion([])
                return
            }

            let items = documents.compactMap { doc -> ListItem2? in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let imagePath = data["image"] as? String else { return nil }
                
                print("📄 Fetched Adventure Item: \(title), Image: \(imagePath)")  // ✅ Debug log
                
                return ListItem2(title: title, image: imagePath)
            }

            completion(items)
        }
    }
        // ✅ Convert gs:// URL to HTTPS
        func getDownloadURL(from gsURL: String, completion: @escaping (String?) -> Void) {
            let storageRef = Storage.storage()

            if gsURL.hasPrefix("gs://") {
                let path = gsURL.replacingOccurrences(of: "gs://raahi-fe1e2.firebasestorage.app/", with: "")
                let ref = storageRef.reference(withPath: path)

                ref.downloadURL { url, error in
                    if let error = error {
                        print("❌ Error fetching download URL: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            } else {
                completion(gsURL)
            }
        }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    func uploadImageAndStoreURL(image: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("adventure/image_\(UUID().uuidString).jpg")
        
        if let imageData = image.pngData() {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("🔥 Upload failed: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                // Get the downloadable URL
                storageRef.downloadURL { url, error in
                    if let url = url {
                        let urlString = url.absoluteString
                        print("✅ Image URL: \(urlString)")
                        
                        // Store the URL in Firestore
                        Firestore.firestore().collection("adventure").addDocument(data: [
                            "title": "Trekking",
                            "image": urlString // Store HTTP URL in Firestore
                        ])
                        
                        completion(urlString)
                    } else {
                        print("⚠️ Failed to get download URL")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    
    // Fetch cities from Firestore
    func fetchCities(completion: @escaping (Result<[StateList], Error>) -> Void) {
        db.collection("stateLists").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Correct conversion: Extracts dictionary values and safely unwraps
            let stateLists: [StateList] = snapshot?.documents.compactMap { document in
                guard let title = document.data()["title"] as? String else { return nil }
                return StateList(id: document.documentID, title: title)
            } ?? []
            
            completion(.success(stateLists))
        }
    }
    
}

