//
//  FirebaseManager.swift
//  RaahiShrey4
//
//  Created by user@59 on 03/02/2025.
//

import Foundation
import Firebase
import FirebaseStorage

struct StateList: Codable {
    let id: String
    let title: String
}

class FirebaseManager {
    
    // Singleton instance
    static let shared = FirebaseManager()
    
    private let databaseRef = Database.database().reference().child("stateList")
    private let storageRef = Storage.storage().reference()
    
    private init() {}

    // MARK: - Fetch Trending Images
    func fetchImageURLs(completion: @escaping ([String]) -> Void) {
        let trendingRef = storageRef.child("trendingHome")
        
        trendingRef.listAll { (result, error) in
            if let error = error {
                print("❌ Error fetching trending images: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var imageURLs: [String] = []
            let dispatchGroup = DispatchGroup()
            
            for item in result?.items ?? [] {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        imageURLs.append(url.absoluteString)
                    } else {
                        print("⚠️ Error getting URL for \(item.name): \(error?.localizedDescription ?? "Unknown error")")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(imageURLs)
            }
        }
    }
    

    
    func fetchInsights(for city: String, completion: @escaping (Result<[Insite], Error>) -> Void) {
            let insightsRef = databaseRef.child("insights").child(city)

            insightsRef.observeSingleEvent(of: .value) { snapshot in
                guard let insightsDict = snapshot.value as? [String: [String: Any]] else {
                    completion(.success([]))
                    return
                }
                
                var insights: [Insite] = []
                for (_, value) in insightsDict {
                    if let title = value["title"] as? String,
                       let type = value["type"] as? String,
                       let price = value["price"] as? String,
                       let imageURL = value["imageURL"] as? String,  // Ensure Firebase stores the image URL
                       let city = value["city"] as? String {
                        
                        insights.append(Insite(title: title, type: type, price: price, imageURL: imageURL, city: city))
                    }
                }
                
                completion(.success(insights))
            } withCancel: { error in
                completion(.failure(error))
            }
        }



    // MARK: - Fetch Adventure Images with Caching
    func fetchImageURLs2(completion: @escaping ([String]) -> Void) {
        let cacheKey = "cachedAdventureImages"
        
        if let cachedImages = UserDefaults.standard.array(forKey: cacheKey) as? [String] {
            print("✅ Using Cached Adventure Images")
            completion(cachedImages)
            return
        }

        let adventureRef = storageRef.child("adventure")
        adventureRef.listAll { (result, error) in
            if let error = error {
                print("❌ Error fetching adventure images: \(error.localizedDescription)")
                completion([])
                return
            }

            var imageURLs: [String] = []
            let dispatchGroup = DispatchGroup()

            for item in result?.items ?? [] {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        imageURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                UserDefaults.standard.setValue(imageURLs, forKey: cacheKey)
                print("🔥 Cached Adventure Image URLs: \(imageURLs)")
                completion(imageURLs)
            }
        }
    }

    // MARK: - Save City to Firebase
    func saveCity(stateList: StateList, completion: @escaping (Result<Void, Error>) -> Void) {
        let stateData: [String: Any] = [
            "id": stateList.id,
            "title": stateList.title
        ]
        
        databaseRef.child(stateList.id).setValue(stateData) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Fetch Cities from Firebase
    func fetchCities(completion: @escaping (Result<[StateList], Error>) -> Void) {
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion(.success([])) // Return empty if no data
                return
            }
            
            let stateLists = value.compactMap { key, stateData -> StateList? in
                guard let id = stateData["id"] as? String, let title = stateData["title"] as? String else {
                    return nil
                }
                return StateList(id: id, title: title)
            }
            completion(.success(stateLists))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
}
