//
//  City.swift
//  RaahiShrey4
//
//  Created by user@59 on 05/11/24.
//

import UIKit

struct City {
    let title : String
    let image : UIImage
}

let cities : [City] = [
    City(title: "Chennai", image: UIImage(named: "chennai 2")!),
    City(title: "Varanasi", image: UIImage(named: "banaras")!),
    City(title: "Kolkata", image: UIImage(named: "kolkata 3")!),
    City(title: "Kochi", image: UIImage(named: "kochi 3")!),
    City(title: "Hyderabad", image: UIImage(named: "hyderbad1")!),
    City(title: "Udaipur", image: UIImage(named: "udaipur 2")!),
    City(title: "Delhi", image: UIImage(named: "delhi 2")!),
    City(title: "Shimla", image: UIImage(named: "shimla")!),
    City(title: "Tirupati", image: UIImage(named: "tirupati")!),
    City(title: "Pondicherry", image: UIImage(named: "pondicherry")!)
    
    ]

struct itinerary {
    let title : String
    let status : String
    let image : UIImage
}

let itineraries : [itinerary] = [
    itinerary(title: "Chennai", status: "Visited", image: UIImage(named: "chennai 2")!),
    itinerary(title: "Varanasi", status: "Visited", image: UIImage(named: "banaras")!),
    itinerary(title: "Kolkata", status: "Visited", image: UIImage(named: "kolkata 3")!),
    itinerary(title: "Kochi", status: "Visited", image: UIImage(named: "kochi 3")!)
    
    ]


struct Diary {
    let caption : String
    let name : String
    let location : String
    let image : UIImage
}

let diaries : [Diary] = [
    Diary(caption: "A Trip To Kolkata", name: "Akshat Rawat", location: "Kolkata", image: UIImage(named: "Diary1")!),
    Diary(caption: "A Trip To Kolkata", name: "Akshat Rawat", location: "Kolkata", image: UIImage(named: "Diary2")!),
    Diary(caption: "A Trip To Kolkata", name: "Akshat Rawat", location: "Kolkata", image: UIImage(named: "Diary3")!),
    Diary(caption: "A Trip To Kolkata", name: "Akshat Rawat", location: "Kolkata", image: UIImage(named: "Diary7")!),
    Diary(caption: "A Trip To Kolkata", name: "Akshat Rawat", location: "Kolkata", image: UIImage(named: "Diary12")!),
    Diary(caption: "A Trip To Kolkata", name: "Akshat Rawat", location: "Kolkata", image: UIImage(named: "Diary6")!)
    
]

struct Selection {
    let title : String
    let image : UIImage
}

let selections : [Selection] = [
    Selection(title: "Adventure", image: UIImage(named: "Diary1")!),
    Selection(title: "Monuments", image: UIImage(named: "Diary2")!),
    Selection(title: "Religious", image: UIImage(named: "Diary3")!),
    Selection(title: "Beaches", image: UIImage(named: "Diary4")!),
    ]


struct Insite {
    let title : String
    let type : String
    let price : String
    let image : UIImage
    
}

let insites : [Insite] = [
    Insite(title: "St. Thomas Cathedral Basilica", type: "Religious", price: "Free", image: UIImage(named: "St Thomas")!),
    Insite(title: "Parthasarthy Temple", type: "Religious", price: "Free", image: UIImage(named: "Parthasarthy")!),
    Insite(title: "Walajah Big Mosque", type: "Religious", price: "Free", image: UIImage(named: "Walajah")!),
    Insite(title: "Meenakshi Temple", type: "Religious", price: "Free", image: UIImage(named: "Mennakshi")!),
    Insite(title: "Blu Flag Beach", type: "Beaches", price: "Free", image: UIImage(named: "Blu Flag")!),
    Insite(title: "VGP Universal Kingdom", type: "Adventure", price: "Rs. 850", image: UIImage(named: "VGP")!),
    Insite(title: "Shore Temple, Mahabalipuram", type: "Beaches", price: "Rs. 50", image: UIImage(named: "Shore Temple")!),
    Insite(title: "Marina Beach", type: "Beaches", price: "Free", image: UIImage(named: "Marina")!),
    
    
    ]


