//
//  UserPostManager.swift
//  RaahiShrey4
//
//  Created by user@59 on 18/03/2025.
//

//import UIKit
//import FirebaseFirestore
//import FirebaseAuth
//
//class UserPostManager {
//    static let shared = UserPostManager()
//    private let db = Firestore.firestore()
//    
//    private init() {
//        // Private initializer to enforce singleton pattern
//    }
//    
//    func fetchUserUploadedPosts(completion: @escaping ([ListItem3]) -> Void) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("❌ No authenticated user found")
//            completion([])
//            return
//        }
//        
//        db.collection("myposts")
//            .whereField("userId", isEqualTo: userId)
//            .order(by: "timestamp", descending: true)
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("❌ Error fetching user posts: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("❌ No posts found for user: \(userId)")
//                    completion([])
//                    return
//                }
//                
//                let posts = documents.compactMap { doc -> ListItem3? in
//                    let data = doc.data()
//                    guard let city = data["city"] as? String,
//                          let imageURLs = data["imageURLs"] as? [String],
//                          let firstImage = imageURLs.first else { return nil }
//                    return ListItem3(title: city, image: firstImage, postID: doc.documentID)
//                }
//                
//                print("✅ Fetched \(posts.count) user-uploaded posts")
//                completion(posts)
//            }
//    }
//    
//    func uploadPost(city: String, date: String, experience: String, imageURLs: [String], itineraryID: String?, completion: @escaping (Result<String, Error>) -> Void) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
//            return
//        }
//        
//        var postData: [String: Any] = [
//            "userId": userId,
//            "city": city,
//            "date": date,
//            "experience": experience,
//            "imageURLs": imageURLs,
//            "timestamp": FieldValue.serverTimestamp()
//        ]
//        
//        if let itineraryID = itineraryID {
//            postData["itineraryID"] = itineraryID
//        }
//        
//        db.collection("myposts").addDocument(data: postData) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success("Post uploaded successfully"))
//            }
//        }
//    }
//}
