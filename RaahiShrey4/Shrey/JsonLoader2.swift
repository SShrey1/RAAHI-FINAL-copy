//
//  JsonLoader.swift
//  RaahiShrey4
//
//  Created by user@59 on 06/02/2025.
//

import Foundation

class JSONLoader {
    static func loadCities() -> [StateList] {
        guard let url = Bundle.main.url(forResource: "stateList", withExtension: "json") else {
            print("Error: stateList.json not found in the bundle.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let stateLists = try JSONDecoder().decode([StateList].self, from: data)
            return stateLists
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}



