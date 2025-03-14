////
////  ItineraryDetailViewController.swift
////  RaahiShrey4
////
////  Created by admin3 on 12/03/25.
////
//import UIKit
//
//class ItineraryDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//    
//    private var itinerary: Itinerary
//    private let collectionView: UICollectionView
//    
//    init(itinerary: Itinerary) {
//        self.itinerary = itinerary
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 120)
//        layout.minimumLineSpacing = 10
//        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = itinerary.name
//        view.backgroundColor = .systemBackground
//        
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(ItineraryCollectionViewCell.self, forCellWithReuseIdentifier: "ItineraryCollectionViewCell")
//        
//        view.addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { itinerary.places.count }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItineraryCollectionViewCell", for: indexPath) as! ItineraryCollectionViewCell
//        cell.configure(with: itinerary.places[indexPath.row])
//        return cell
//    }
//}
//
