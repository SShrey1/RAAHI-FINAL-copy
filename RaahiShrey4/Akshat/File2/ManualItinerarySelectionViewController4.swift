//
//  ViewController4.swift
//  RAAHI
//
//  Created by admin3 on 05/11/24.
//
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore

class ManualItinerarySelectionViewController4: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    
    @IBOutlet weak var manualSearchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var table4: UITableView!
    @IBOutlet weak var table5: UITableView!
    
    struct ManualItineraryList {
            let title: String
            let category: String
            let duration: String
            let image: String
            let city: String
        }

        // Data array
    var data: [ManualItineraryList] = [
           ManualItineraryList(title: "Gateway Of India", category: "Catholic Cathedral", duration: "Duration: 1-2 hours", image: "image 57", city: "Chennai"),
           ManualItineraryList(title: "Elephanta Caves", category: "Hindu Temple", duration: "Duration: 1-2 hours", image: "image 52", city: "Chennai"),
           ManualItineraryList(title: "VGP Universal Kingdom", category: "Amusement Park", duration: "Duration: 3-4 hours", image: "image 235", city: "Chennai"),
           ManualItineraryList(title: "Walajah Big Mosque", category: "Mosque", duration: "Duration: 3-4 hours", image: "image 59", city: "Chennai"),
           ManualItineraryList(title: "St. Thomas Cathedral Basilica", category: "Catholic Cathedral", duration: "Duration: 1-2 hours", image: "image 57", city: "Chennai"),
           ManualItineraryList(title: "Arulmigu Shri Parthasarthy Perumal Temple", category: "Hindu Temple", duration: "Duration: 1-2 hours", image: "image 52", city: "Chennai"),
           ManualItineraryList(title: "VGP Universal Kingdom", category: "Amusement Park", duration: "Duration: 3-4 hours", image: "image 235", city: "Chennai"),
           ManualItineraryList(title: "Walajah Big Mosque", category: "Mosque", duration: "Duration: 3-4 hours", image: "image 59", city: "Chennai"),
           
           ManualItineraryList(title: "St. Thomas Cathedral Basilica", category: "Catholic Cathedral", duration: "Duration: 1-2 hours", image: "image 57", city: "Mumbai"),
           ManualItineraryList(title: "Arulmigu Shri Parthasarthy Perumal Temple", category: "Hindu Temple", duration: "Duration: 1-2 hours", image: "image 52", city: "Mumbai"),
           ManualItineraryList(title: "VGP Universal Kingdom", category: "Amusement Park", duration: "Duration: 3-4 hours", image: "image 235", city: "Mumbai"),
           ManualItineraryList(title: "Walajah Big Mosque", category: "Mosque", duration: "Duration: 3-4 hours", image: "image 59", city: "Mumbai"),
           ManualItineraryList(title: "St. Thomas Cathedral Basilica", category: "Catholic Cathedral", duration: "Duration: 1-2 hours", image: "image 57", city: "Mumbai"),
           ManualItineraryList(title: "Arulmigu Shri Parthasarthy Perumal Temple", category: "Hindu Temple", duration: "Duration: 1-2 hours", image: "image 52", city: "Mumbai"),
           ManualItineraryList(title: "VGP Universal Kingdom", category: "Amusement Park", duration: "Duration: 3-4 hours", image: "image 235", city: "Mumbai"),
           ManualItineraryList(title: "Walajah Big Mosque", category: "Mosque", duration: "Duration: 3-4 hours", image: "image 59", city: "Mumbai"),
           
           
           ManualItineraryList(title: "Narendra Modi Ground", category: "Catholic Cathedral", duration: "Duration: 1-2 hours", image: "image 57", city: "Ahmedabad"),
           ManualItineraryList(title: "Arulmigu Shri Parthasarthy Perumal Temple", category: "Hindu Temple", duration: "Duration: 1-2 hours", image: "image 52", city: "Ahmedabad"),
           ManualItineraryList(title: "VGP Universal Kingdom", category: "Amusement Park", duration: "Duration: 3-4 hours", image: "image 235", city: "Ahmedabad"),
           ManualItineraryList(title: "Walajah Big Mosque", category: "Mosque", duration: "Duration: 3-4 hours", image: "image 59", city: "Ahmedabad"),
           ManualItineraryList(title: "St. Thomas Cathedral Basilica", category: "Catholic Cathedral", duration: "Duration: 1-2 hours", image: "image 57", city: "Ahmedabad"),
           ManualItineraryList(title: "Arulmigu Shri Parthasarthy Perumal Temple", category: "Hindu Temple", duration: "Duration: 1-2 hours", image: "image 52", city: "Ahmedabad"),
           ManualItineraryList(title: "VGP Universal Kingdom", category: "Amusement Park", duration: "Duration: 3-4 hours", image: "image 235", city: "Ahmedabad"),
           ManualItineraryList(title: "Walajah Big Mosque", category: "Mosque", duration: "Duration: 3-4 hours", image: "image 59", city: "Ahmedabad")
           
           
           
       ]

    var filteredData: [ManualItineraryList] = []
        var selectedCity: String? // Selected city for filtering
        var selectedItinerary: [String: [ManualItineraryList]] = [:]
        let maxPlacesPerDay = 3
        let firestore = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manualSearchBar.delegate = self
        table4.dataSource = self
        table4.delegate = self
        table4.rowHeight = 100

        // Retrieve selected city from UserDefaults
        selectedCity = UserDefaults.standard.string(forKey: "selectedCity")
        
        filterItinerariesByCity() // Apply filtering based on selected city
    }

        func filterItinerariesByCity() {
            if let city = selectedCity {
                filteredData = data.filter { $0.city == city }
            } else {
                filteredData = data // Show all if no city is selected
            }
            table4.reloadData()
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredData.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let itineraryItem = filteredData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CustomTableViewCell1
            cell.Title1.text = itineraryItem.title
            cell.iconImageView.image = UIImage(named: itineraryItem.image)
            cell.iconImageView.layer.cornerRadius = 10
            cell.iconImageView.clipsToBounds = true

            cell.addAction = { [weak self] in
                print("Add button tapped for: \(itineraryItem.title)")
                self?.addToItinerary(itineraryItem)
            }

            return cell
        }

        func addToItinerary(_ item: ManualItineraryList) {
            var dayNumber = 1

            while selectedItinerary["Day \(dayNumber)"]?.count == maxPlacesPerDay {
                dayNumber += 1
            }

            let dayKey = "Day \(dayNumber)"
            if selectedItinerary[dayKey] != nil {
                selectedItinerary[dayKey]?.append(item)
            } else {
                selectedItinerary[dayKey] = [item]
            }

            print("Updated Itinerary: \(selectedItinerary)")
            saveToFirestore()
        }

        func saveToFirestore() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not logged in.")
                return
            }

            let itineraryData = selectedItinerary.mapValues { items in
                items.map { [
                    "title": $0.title,
                    "category": $0.category,
                    "duration": $0.duration,
                    "city": $0.city
                ]}
            }

            firestore.collection("users").document(userID).collection("manual_itinerary").document("selected_places").setData(itineraryData) { error in
                if let error = error {
                    print("Error saving data: \(error.localizedDescription)")
                } else {
                    print("Itinerary successfully saved in Firestore!")
                }
            }
        }
    }
    
    
    
    
//    var filteredData: [ManualItineraryList] = []
//       var selectedItinerary: [String: [ManualItineraryList]] = [:] // Stores selected places per day
//       let maxPlacesPerDay = 3 // Limit per day
//
//       let firestore = Firestore.firestore() // Firestore reference
//
//       override func viewDidLoad() {
//           super.viewDidLoad()
//           filteredData = data
//           manualSearchBar.delegate = self
//           table4.dataSource = self
//           table4.delegate = self
//           table4.rowHeight = 100 // Set row height to 100
//       }
//
//       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//           return filteredData.count
//       }
//
//       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//           let itineraryItem = filteredData[indexPath.row]
//           let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CustomTableViewCell1
//           cell.Title1.text = itineraryItem.title
//           cell.iconImageView.image = UIImage(named: itineraryItem.image)
//           cell.iconImageView.layer.cornerRadius = 10
//           cell.iconImageView.clipsToBounds = true
//
//           // Add button action
//           cell.addAction = { [weak self] in
//               print("Add button tapped for: \(itineraryItem.title)")
//               self?.addToItinerary(itineraryItem)
//           }
//
//           return cell
//       }
//
//       func addToItinerary(_ item: ManualItineraryList) {
//           var dayNumber = 1
//
//           // Find the appropriate day
//           while selectedItinerary["Day \(dayNumber)"]?.count == maxPlacesPerDay {
//               dayNumber += 1
//           }
//
//           let dayKey = "Day \(dayNumber)"
//
//           // Add item to the day
//           if selectedItinerary[dayKey] != nil {
//               selectedItinerary[dayKey]?.append(item)
//           } else {
//               selectedItinerary[dayKey] = [item]
//           }
//
//           // Debug: Print itinerary before saving
//           print("Updated Itinerary: \(selectedItinerary)")
//
//           // Save to Firestore
//           saveToFirestore()
//       }
//
//       func saveToFirestore() {
//           guard let userID = Auth.auth().currentUser?.uid else {
//               print("User not logged in.")
//               return
//           }
//
//           let itineraryData = selectedItinerary.mapValues { items in
//               items.map { [
//                   "title": $0.title,
//                   "category": $0.category,
//                   "duration": $0.duration,
//                   "city": $0.city
//               ]}
//           }
//
//           // Save inside "manual_itinerary" collection in Firestore
//           firestore.collection("users").document(userID).collection("manual_itinerary").document("selected_places").setData(itineraryData) { error in
//               if let error = error {
//                   print("Error saving data: \(error.localizedDescription)")
//               } else {
//                   print("Itinerary successfully saved in Firestore!")
//               }
//           }
//       }
//   }

    
    
    
    
    
    
    
//    var filteredData: [ManualItineraryList] = []
//        var selectedItinerary: [String: [ManualItineraryList]] = [:] // Stores selected places per day
//        let maxPlacesPerDay = 3 // Limit per day
//        let firestore = Firestore.firestore() // Firestore reference
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        table4.dataSource = self
//        table4.delegate = self
//        table4.rowHeight = 100
//        
//        manualSearchBar.delegate = self
//        
//        // Get the selected city from UserDefaults
//        let selectedCity = UserDefaults.standard.string(forKey: "selectedCity")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//        print("Selected City from UserDefaults: '\(selectedCity)'") // Debugging step
//        
//        // Filter data based on the selected city
//        filterData(for: selectedCity)
//    }
//
//
//    func filterData(for city: String) {
//        filteredData = data.filter { $0.city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
//        
//        print("Filtered Data Count: \(filteredData.count)") // Debugging step
//        for item in filteredData {
//            print("Filtered Item: \(item.title) - \(item.city)") // Print items being added
//        }
//        
//        table4.reloadData() // Ensure table reloads
//    }
//
//
//        // TableView Methods
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("Number of rows to display: \(filteredData.count)")
//        return filteredData.count
//    }
//
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let itineraryItem = filteredData[indexPath.row]
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CustomTableViewCell1
//            cell.Title1.text = itineraryItem.title
//            cell.iconImageView.image = UIImage(named: itineraryItem.image)
//            cell.iconImageView.layer.cornerRadius = 10
//            cell.iconImageView.clipsToBounds = true
//
//            // Add button action
//            cell.addAction = { [weak self] in
//                print("Add button tapped for: \(itineraryItem.title)")
//                self?.addToItinerary(itineraryItem)
//            }
//
//            return cell
//        }
//
//        func addToItinerary(_ item: ManualItineraryList) {
//            var dayNumber = 1
//
//            // Find the appropriate day
//            while selectedItinerary["Day \(dayNumber)"]?.count == maxPlacesPerDay {
//                dayNumber += 1
//            }
//
//            let dayKey = "Day \(dayNumber)"
//
//            // Add item to the day
//            if selectedItinerary[dayKey] != nil {
//                selectedItinerary[dayKey]?.append(item)
//            } else {
//                selectedItinerary[dayKey] = [item]
//            }
//
//            // Debug: Print itinerary before saving
//            print("Updated Itinerary: \(selectedItinerary)")
//
//            // Save to Firestore
//            saveToFirestore(for: item.city)
//        }
//
//        func saveToFirestore(for city: String) {
//            guard let userID = Auth.auth().currentUser?.uid else {
//                print("User not logged in.")
//                return
//            }
//
//            let itineraryData = selectedItinerary.mapValues { items in
//                items.map { [
//                    "title": $0.title,
//                    "category": $0.category,
//                    "duration": $0.duration,
//                    "city": $0.city
//                ]}
//            }
//
//            // Save inside "manual_itinerary" collection under the city
//            firestore.collection("users").document(userID).collection("manual_itinerary").document(city).setData(itineraryData) { error in
//                if let error = error {
//                    print("Error saving data: \(error.localizedDescription)")
//                } else {
//                    print("Itinerary successfully saved in Firestore under \(city)!")
//                }
//            }
//        }
//    }
