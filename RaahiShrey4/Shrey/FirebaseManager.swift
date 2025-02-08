//
//  FirebaseManager.swift
//  RaahiShrey4
//
//  Created by user@59 on 03/02/2025.
//

import Foundation
import Firebase
import FirebaseStorage

struct StateList : Codable{
    let id: String
    let title: String
}

class FirebaseManager {
    static let shared = FirebaseManager()

    private let databaseRef = Database.database().reference().child("stateList")
    
    private init() {}

    func fetchImageURLs(completion: @escaping ([String]) -> Void) {
        let storageRef = Storage.storage().reference().child("trendingHome") // Folder path
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error fetching images: \(error)")
                completion([])
                return
            }
            
            var imageURLs: [String] = []
            let dispatchGroup = DispatchGroup()
            
            for item in result!.items {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        print("Fetched Image URL: \(url.absoluteString)") // Debug print
                        imageURLs.append(url.absoluteString)
                    } else {
                        print("Error getting URL for \(item.name): \(error?.localizedDescription ?? "Unknown error")")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(imageURLs)
            }
        }
    }
    
    
    func fetchImageURLs2(completion: @escaping ([String]) -> Void) {
        if let cachedImages = UserDefaults.standard.array(forKey: "cachedAdventureImages") as? [String] {
            print("✅ Using Cached Images")
            completion(cachedImages)
            return
        }

        let storageRef = Storage.storage().reference().child("adventure")
        storageRef.listAll { (result, error) in
            if let error = error {
                print("❌ Error fetching images: \(error)")
                completion([])
                return
            }

            var imageURLs: [String] = []
            let dispatchGroup = DispatchGroup()

            for item in result!.items {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        imageURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                UserDefaults.standard.setValue(imageURLs, forKey: "cachedAdventureImages")
                print("🔥 Caching Image URLs: \(imageURLs)")
                completion(imageURLs)
            }
        }
    }

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

    func fetchCities(completion: @escaping (Result<[StateList], Error>) -> Void) {
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion(.success([])) // Return empty if no data
                return
            }
            
            let stateLists = value.compactMap { key, stateData -> StateList? in
                guard
                    let id = stateData["id"] as? String,
                    let title = stateData["title"] as? String
                else {
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
