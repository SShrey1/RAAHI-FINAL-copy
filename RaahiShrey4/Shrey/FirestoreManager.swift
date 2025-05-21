//
//  FireStoreManager.swift
//  RaahiShrey4
//
//  Created by user@59 on 13/02/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

// MARK: - Data Models
struct StateList: Codable {
    let id: String
    let title: String
}

struct ListItem {
    let title: String
    let image: String
    let city: String
}

struct ListItem2 {
    let title: String
    let image: String
}

struct ListItem3 {
    let title: String
    let image: String
    let postID: String
}

struct trendingzData {
    var image: String
    var about: String
    var title: String
}

struct Post {
    let id: String
    let city: String
    let date: String
    let experience: String
    let imageURLs: [String]
    let itineraryID: String?
    
    init?(id: String, data: [String: Any]) {
        guard let city = data["city"] as? String,
              let date = data["date"] as? String,
              let experience = data["experience"] as? String,
              let imageURLs = data["imageURLs"] as? [String] else {
            return nil
        }
        self.id = id
        self.city = city
        self.date = date
        self.experience = experience
        self.imageURLs = imageURLs
        self.itineraryID = data["itineraryID"] as? String
    }
}

// MARK: - FirestoreHelper
class FirestoreHelper {
    static let shared = FirestoreHelper()
    private let db = Firestore.firestore()
    
    func fetchUserPosts(completion: @escaping ([ListItem3]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user found")
            completion([])
            return
        }
        
        db.collection("myposts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Firestore User Posts Fetch Error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("❌ No posts found for user: \(userId)")
                    completion([])
                    return
                }
                
                let items = documents.compactMap { doc -> ListItem3? in
                    let data = doc.data()
                    guard let city = data["city"] as? String,
                          let imageURLs = data["imageURLs"] as? [String],
                          let firstImage = imageURLs.first else { return nil }
                    return ListItem3(title: city, image: firstImage, postID: doc.documentID)
                }
                
                print("🔥 Firebase User Posts Fetched: \(items.count) items")
                completion(items)
            }
    }
    
    func fetchPost(by postID: String, completion: @escaping (Post?) -> Void) {
        db.collection("myposts")
            .document(postID)
            .getDocument { document, error in
                if let error = error {
                    print("❌ Error fetching post: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let document = document, document.exists, let data = document.data(),
                      let post = Post(id: document.documentID, data: data) else {
                    print("❌ No post found for ID: \(postID)")
                    completion(nil)
                    return
                }
                completion(post)
            }
    }
    
    func fetchTrendingItems(for city: String, completion: @escaping ([ListItem]) -> Void) {
        db.collection("famous")
            .whereField("city", isEqualTo: city)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Firestore Trending Fetch Error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("❌ No Trending documents found for city: \(city)")
                    completion([])
                    return
                }
                let items = documents.compactMap { doc -> ListItem? in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let imagePath = data["image"] as? String,
                          let city = data["city"] as? String else { return nil }
                    return ListItem(title: title, image: imagePath, city: city)
                }
                print("🔥 Firebase Trending Data Fetched for \(city): \(items.count) items")
                completion(items)
            }
    }
    
    func fetchAdventureItems(completion: @escaping ([ListItem2]) -> Void) {
        db.collection("adventure")
            .getDocuments { snapshot, error in
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
                    return ListItem2(title: title, image: imagePath)
                }
                print("🔥 Firebase Adventure Data Fetched: \(items.count) items")
                completion(items)
            }
    }
    
    func fetchTrendingItem(by title: String, completion: @escaping (trendingzData?) -> Void) {
        db.collection("FamousView")
            .whereField("title", isEqualTo: title)
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
                    completion(nil)
                    return
                }
                print("📄 Fetched Trending Item: \(title), Image: \(image), About: \(about)")
                completion(trendingzData(image: image, about: about, title: title))
            }
    }
    
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
    
    func uploadImageAndStoreURL(image: UIImage, title: String, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("adventure/image_\(UUID().uuidString).jpg")
        if let imageData = image.pngData() {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("🔥 Upload failed: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                storageRef.downloadURL { url, error in
                    if let url = url {
                        let urlString = url.absoluteString
                        print("✅ Image URL: \(urlString)")
                        Firestore.firestore().collection("adventure").addDocument(data: [
                            "title": title,
                            "image": urlString
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
    
    func fetchCities(completion: @escaping (Result<[StateList], Error>) -> Void) {
        db.collection("stateLists")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let stateLists: [StateList] = snapshot?.documents.compactMap { document in
                    guard let title = document.data()["title"] as? String else { return nil }
                    return StateList(id: document.documentID, title: title)
                } ?? []
                completion(.success(stateLists))
            }
    }
}
