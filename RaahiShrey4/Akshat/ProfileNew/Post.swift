//
//  Post.swift
//  RaahiShrey4
//
//  Created by admin3 on 12/03/25.
//

import Foundation

struct Post {
    let id: String
    let city: String
    let date: String
    let experience: String
    let imageURLs: [String]
    
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
    }
}
