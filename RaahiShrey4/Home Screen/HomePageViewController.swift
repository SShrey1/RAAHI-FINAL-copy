
//import UIKit
//import FirebaseStorage
//import Firebase
//import FirebaseFirestore
//
//class HomePageViewController: UIViewController, CitySelectionDelegate {
//    func didSelectCity(_ city: String) {
//        cityUpdateLabel.text = city
//        
//    }
//    
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var settingsButton: UIButton!
//    @IBOutlet weak var profileButton: UIButton!
//    @IBOutlet weak var cityUpdateLabel: UILabel!
//    @IBOutlet weak var showItinerariesButton: UIButton!
//    
//        private var adventureItems: [ListItem2] = []
//        private var sections = MockData.shared.pageData
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "NationalParkViewController",
//               let destinationVC = segue.destination as? NationalParkViewController {
//                destinationVC.selectedCity = cityUpdateLabel.text
//            }
//            if segue.identifier == "ShowMyItineraries",
//               let destinationVC = segue.destination as? TripPlanCardViewController {
//                if let savedCity = UserDefaults.standard.string(forKey: "selectedCity") {
//                    destinationVC.currentCity = savedCity // This should now work
//                }
//            }
//        }
//    
//        override func viewDidLoad() {
//            super.viewDidLoad()
//    
//            UserDefaults.standard.removeObject(forKey: "selectedCity")
//    
//            collectionView.collectionViewLayout = createLayout()
//            
//            updateCityLabel()
//    
//            NotificationCenter.default.addObserver(self, selector: #selector(updateCityLabel), name: Notification.Name("CityUpdated"), object: nil)
//    
//            fetchAdventureData() // Fetch adventure data
//       
//            
//            if let savedCity = UserDefaults.standard.string(forKey: "selectedCity") {
//                    fetchTrendingData(for: savedCity)  // ✅ Fetch Trending data from Firestore
//                }
//
//                fetchAdventureData()
//            
//    
//        }
//    
//    
//    
//    
//    
//    
//    
//    @IBAction func showItineraries(_ sender: UIButton) {
//        performSegue(withIdentifier: "ShowMyItineraries", sender: nil)
//    }
//    
//    
//    @IBAction func profileButtontapped(_ sender: UIButton) {
//        let profileVC = ProfileViewController1()
//        navigationController?.pushViewController(profileVC, animated: true)
//    }
//    
//    
//    
//    @objc func updateCityLabel() {
//        if let savedCity = UserDefaults.standard.string(forKey: "selectedCity") {
//            cityUpdateLabel.text = savedCity
//            print("🏙️ Selected city updated to: \(savedCity)")
//            
//            // ✅ Save selected city to UserDefaults to be used in NationalParkViewController
//            UserDefaults.standard.set(savedCity, forKey: "selectedCity")
//            
//            fetchTrendingData(for: savedCity) // ✅ Fetch Trending data based on selected city
//        } else {
//            cityUpdateLabel.text = "Select City"
//        }
//    }
//    
//    
//    
//
//    
//    
//    
//    private func fetchTrendingData(for city: String) {
//        FirestoreHelper.shared.fetchTrendingItems(for: city) { [weak self] items in
//            guard let self = self else { return }
//
//            print("🔥 Firebase Trending Data Fetched for \(city): \(items.count) items")  // ✅ Debug log
//
//            // ✅ Update Trending section
//            if let index = self.sections.firstIndex(where: { if case .trending = $0 { return true } else { return false } }) {
//                self.sections[index] = .trending(items)
//            } else {
//                self.sections.append(.trending(items))
//            }
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//                print("✅ CollectionView Reloaded with Firebase Trending Data")  // ✅ Debug log
//            }
//        }
//    }
//    
//    // ✅ Fetch Adventure Data from Firestore
//    private func fetchAdventureData() {
//        FirestoreHelper.shared.fetchAdventureItems { [weak self] items in
//            guard let self = self else { return }
//
//            print("🔥 Firebase Adventure Data Fetched: \(items.count) items")  // ✅ Debug log
//
//            // ✅ Update adventure section
//            if let index = self.sections.firstIndex(where: { if case .adventure = $0 { return true } else { return false } }) {
//                self.sections[index] = .adventure(items)
//            } else {
//                self.sections.append(.adventure(items))
//            }
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//                print("✅ CollectionView Reloaded with Firebase Data")  // ✅ Debug log
//            }
//        }
//    }
//    
//        private func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
//            return NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1),
//                    heightDimension: .absolute(50)  // Adjust as needed
//                ),
//                elementKind: UICollectionView.elementKindSectionHeader,
//                alignment: .top
//            )
//        }
// 
//        private func createLayout() -> UICollectionViewCompositionalLayout {
//            UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
//                guard let self = self else { return nil }
//                let section = self.sections[sectionIndex]
//    
//                switch section {
//                case .trending:
//                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
//                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(160), heightDimension: .absolute(204)), subitems: [item])
//                    let section = NSCollectionLayoutSection(group: group)
//                    section.orthogonalScrollingBehavior = .continuous
//                    section.interGroupSpacing = 10
//                    section.contentInsets = .init(top: 0, leading: 10, bottom: 10, trailing: 7)
//                    section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
//                    section.supplementariesFollowContentInsets = false
//                    return section
//    
//                case .adventure:
//                    let item = NSCollectionLayoutItem(
//                        layoutSize: .init(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .fractionalHeight(1)
//                        )
//                    )
//            let group = NSCollectionLayoutGroup.horizontal(
//                layoutSize: .init(
//                    widthDimension: .absolute(110),  // Match the width
//                    heightDimension: .absolute(110)  // Make it square for circular images
//                ),
//                subitems: [item]
//            )
//                    let section = NSCollectionLayoutSection(group: group)
//                    section.orthogonalScrollingBehavior = .continuous  // Match scrolling behavior
//                    section.interGroupSpacing = 0
//                    section.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 7)  // Match margins
//                    section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
//                    section.supplementariesFollowContentInsets = false
//            return section
//    
//                case .diary:
//                    let item = NSCollectionLayoutItem(
//                        layoutSize: .init(
//                            widthDimension: .fractionalWidth(1),  // Each item fills the group
//                            heightDimension: .fractionalHeight(1) // Full height of the group
//                        )
//                    )
//                    
//                    // Group containing two items in a row
//                    let group = NSCollectionLayoutGroup.horizontal(
//                        layoutSize: .init(
//                            widthDimension: .fractionalWidth(1),  // Group width matches the section width
//                            heightDimension: .absolute(215)       // Fixed height for the cards
//                        ),
//                        subitem: item,
//                        count: 2 // Two items side by side
//                    )
//                    group.interItemSpacing = .fixed(10)  // Spacing between items within a row
//                    
//                    let section = NSCollectionLayoutSection(group: group)
//                    section.interGroupSpacing = 10  // Vertical spacing between rows
//                    section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 5)  // Padding around the section
//                    
//                    section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
//                    section.supplementariesFollowContentInsets = false
//                    return section
//                }
//            }
//        }
//}
//    
//    extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//        func numberOfSections(in collectionView: UICollectionView) -> Int {
//            return sections.count
//        }
//        
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            switch sections[section]
//        {
//            case .adventure(let items):
//                return items.count
//            case .trending(let items):
//                return items.count
//            case .diary(let items):
//                return items.count
//            }
//        }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch sections[indexPath.section] {
//        case .trending(let items):
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as! Story2CollectionViewCell
//            
//            cell.setup(items[indexPath.row])
//            
//            return cell
//        case .adventure(let items):
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortraitCollectionViewCell", for: indexPath) as! PortraitCollectionViewCell
//            FirebaseManager.shared.fetchImageURLs2 { urls in
//                if indexPath.row < urls.count {
//                    let updatedItem = ListItem2(title: items[indexPath.row].title, image: urls[indexPath.row])
//                    DispatchQueue.main.async {
//                        cell.setup(updatedItem)
//                    }
//                }
//            }
//            return cell
//        case .diary(let items): 
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LandscapeCollectionViewCell", for: indexPath) as! LandscapeCollectionViewCell
//            cell.setup(items[indexPath.row])
//            return cell
//            
//        }
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewHeaderReusableView", for: indexPath) as! CollectionViewHeaderReusableView
//            header.setup(sections[indexPath.section].title)
//            return header
//        default:
//            return UICollectionReusableView()
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//            switch sections[indexPath.section] {
//                
//            case .trending(let items):
//                    let selectedItem = items[indexPath.row]  // ✅ Get the selected cell's title
//                    print("📝 Selected Trending Title: \(selectedItem.title)") // ✅ Print title to terminal
//                    
//                    if let trendingVC = storyboard?.instantiateViewController(withIdentifier: "TrendingzViewController") as? TrendingzViewController {
//                        trendingVC.selectedTrendingTitle = selectedItem.title  // ✅ Pass the title
//                        navigationController?.pushViewController(trendingVC, animated: true)
//                    }
//                    
//
//            case .adventure(let items):
//                let selectedItem = items[indexPath.row]
//                print("🎯 Selected Adventure Title: \(selectedItem.title)")
//                var viewController: UIViewController?
//                
//                switch selectedItem.title {
//                case "Trekking":
//                    viewController = storyboard?.instantiateViewController(withIdentifier: "RaftingViewController")
//                case "Safari":
//                    viewController = storyboard?.instantiateViewController(withIdentifier: "NationalParkViewController")
//                case "Bungee":
//                    viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController4")
//                case "Rafting":
//                    viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController2")
//                case "Sky Diving":
//                    viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController3")
//                default:
//                    break
//                }
//                
//                if let viewController = viewController {
//                    navigationController?.pushViewController(viewController, animated: true)
//                }
//                
//            default:
//                break
//            }
//        }
//}
//
//


import UIKit
import FirebaseStorage
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SDWebImage // For image loading

class HomePageViewController: UIViewController, CitySelectionDelegate {
    func didSelectCity(_ city: String) {
        
        cityUpdateLabel.text = city
        
        
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var cityUpdateLabel: UILabel!
    @IBOutlet weak var showItinerariesButton: UIButton!
    
    private var sections: [Section] = []
    
    enum Section {
        case trending([ListItem])
        case adventure([ListItem2])
        case diary([ListItem3])
        
        var title: String {
            switch self {
            case .trending: return "Trending"
            case .adventure: return "Adventure"
            case .diary: return "Traveller's Diary"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.removeObject(forKey: "selectedCity")
        
        // Initialize sections
        sections = [
            .trending([]),
            .adventure([]),
            .diary([])
        ]
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cells and header programmatically
        collectionView.register(Story2CollectionViewCell.self, forCellWithReuseIdentifier: "StoryCollectionViewCell")
        collectionView.register(PortraitCollectionViewCell.self, forCellWithReuseIdentifier: "PortraitCollectionViewCell")
        collectionView.register(LandscapeCollectionViewCell.self, forCellWithReuseIdentifier: "LandscapeCollectionViewCell")
        collectionView.register(CollectionViewHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeaderReusableView")
        
        updateCityLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCityLabel), name: Notification.Name("CityUpdated"), object: nil)
        
        if Auth.auth().currentUser == nil {
            print("⚠️ No user logged in. Posts will not be fetched.")
        }
        
        fetchAdventureData()
        if let savedCity = UserDefaults.standard.string(forKey: "selectedCity") {
            fetchTrendingData(for: savedCity)
        }
        fetchUserPosts()
    }
    
    @objc private func updateCityLabel() {
        if let savedCity = UserDefaults.standard.string(forKey: "selectedCity") {
            cityUpdateLabel.text = savedCity
            print("🏙️ Selected city updated to: \(savedCity)")
            UserDefaults.standard.set(savedCity, forKey: "selectedCity")
            fetchTrendingData(for: savedCity)
        } else {
            cityUpdateLabel.text = "Select City"
        }
    }
    
    private func fetchTrendingData(for city: String) {
        FirestoreHelper.shared.fetchTrendingItems(for: city) { [weak self] items in
            guard let self = self else { return }
            if let index = self.sections.firstIndex(where: { if case .trending = $0 { return true } else { return false } }) {
                self.sections[index] = .trending(items)
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(integer: index))
                }
            }
        }
    }
    
    private func fetchAdventureData() {
        FirestoreHelper.shared.fetchAdventureItems { [weak self] items in
            guard let self = self else { return }
            if let index = self.sections.firstIndex(where: { if case .adventure = $0 { return true } else { return false } }) {
                self.sections[index] = .adventure(items)
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(integer: index))
                }
            }
        }
    }
    
    private func fetchUserPosts() {
        FirestoreHelper.shared.fetchUserPosts { [weak self] items in
            guard let self = self else { return }
            if let index = self.sections.firstIndex(where: { if case .diary = $0 { return true } else { return false } }) {
                self.sections[index] = .diary(items)
                print("✅ Updated Traveller's Diary section with \(items.count) items")
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(integer: index))
                }
            }
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else { return nil }
            let section = self.sections[sectionIndex]
            switch section {
            case .trending:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(160), heightDimension: .absolute(204)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = .init(top: 0, leading: 10, bottom: 10, trailing: 7)
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                return section
                
            case .adventure:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(110), heightDimension: .absolute(110)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 0
                section.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 7)
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                return section
                
            case .diary:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(215)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                return section
            }
        }
    }
    
    private func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .trending(let items): return items.count
        case .adventure(let items): return items.count
        case .diary(let items): return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .trending(let items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as! Story2CollectionViewCell
            cell.setup(items[indexPath.row])
            return cell
            
        case .adventure(let items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortraitCollectionViewCell", for: indexPath) as! PortraitCollectionViewCell
            cell.setup(items[indexPath.row])
            return cell
            
        case .diary(let items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LandscapeCollectionViewCell", for: indexPath) as! LandscapeCollectionViewCell
            cell.setup(items[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewHeaderReusableView", for: indexPath) as! CollectionViewHeaderReusableView
        header.setup(sections[indexPath.section].title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .trending(let items):
            let selectedItem = items[indexPath.row]
            if let trendingVC = storyboard?.instantiateViewController(withIdentifier: "TrendingzViewController") as? TrendingzViewController {
                trendingVC.selectedTrendingTitle = selectedItem.title
                navigationController?.pushViewController(trendingVC, animated: true)
            }
            
        case .adventure(let items):
            let selectedItem = items[indexPath.row]
            var viewController: UIViewController?
            switch selectedItem.title {
            case "Trekking": viewController = storyboard?.instantiateViewController(withIdentifier: "RaftingViewController")
            case "Safari": viewController = storyboard?.instantiateViewController(withIdentifier: "NationalParkViewController")
            case "Bungee": viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController4")
            case "Rafting": viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController2")
            case "Sky Diving": viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController3")
            default: break
            }
            if let viewController = viewController {
                navigationController?.pushViewController(viewController, animated: true)
            }
            
        case .diary(let items):
            let selectedItem = items[indexPath.row]
            FirestoreHelper.shared.fetchPost(by: selectedItem.postID) { [weak self] post in
                guard let self = self, let post = post else { return }
                let postDetailVC = Post2DetailViewController(post: post)
                self.navigationController?.pushViewController(postDetailVC, animated: true)
            }
        }
    }
}
