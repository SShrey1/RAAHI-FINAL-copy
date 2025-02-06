//
//  FirebaseManager.swift
//  RaahiShrey4
//
//  Created by user@59 on 03/02/2025.
//

import Foundation
import Firebase


struct StateList : Codable{
    let id: String
    let title: String
}

class FirebaseManager {
    static let shared = FirebaseManager()

    private let databaseRef = Database.database().reference().child("stateList")

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
