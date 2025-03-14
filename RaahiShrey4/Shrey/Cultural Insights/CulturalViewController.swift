import UIKit
import Firebase
import FirebaseFirestore
import SDWebImage

class CulturalViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Outlets
    @IBOutlet weak var CulturalLabel: UILabel!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var adventureImage: UIImageView!
    @IBOutlet weak var advenLabel: UILabel!
    @IBOutlet weak var monImage: UIImageView!
    @IBOutlet weak var monLabel: UILabel!
    @IBOutlet weak var beachImage: UIImageView!
    @IBOutlet weak var beachesLabel: UILabel!
    @IBOutlet weak var shrineaImage: UIImageView!
    @IBOutlet weak var shrinesLabel: UILabel!
    @IBOutlet weak var insightsSearchBar: UISearchBar!
    @IBOutlet weak var insightsCollectionView: UICollectionView!

    // MARK: - Properties
    var searchedInsites: [Insite] = []
    private var searchTimer: Timer?
    private let db = Firestore.firestore()
    private var isSegueBeingPerformed = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupSearchBar()
        setupImageTapGestures()
        setupNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadInsights()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        // Set up labels and images
        CulturalLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        CityLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        CityLabel.textColor = .secondaryLabel

        // Add shadows and rounded corners to images
        [adventureImage, monImage, beachImage, shrineaImage].forEach { imageView in
            imageView.layer.cornerRadius = 12
            imageView.layer.shadowColor = UIColor.black.cgColor
            imageView.layer.shadowOpacity = 0.2
            imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
            imageView.layer.shadowRadius = 4
            imageView.layer.masksToBounds = false
        }
    }

    private func setupCollectionView() {
        insightsCollectionView.delegate = self
        insightsCollectionView.dataSource = self
        insightsCollectionView.prefetchDataSource = self
        insightsCollectionView.collectionViewLayout = createCollectionViewLayout()

        // Add pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        insightsCollectionView.refreshControl = refreshControl
    }

    private func setupSearchBar() {
        insightsSearchBar.delegate = self
        insightsSearchBar.placeholder = "Search insights..."
        insightsSearchBar.showsCancelButton = true
    }

    private func setupImageTapGestures() {
        let adventureTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterByAdventure))
        adventureImage.isUserInteractionEnabled = true
        adventureImage.addGestureRecognizer(adventureTapGesture)

        let monumentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterByMonuments))
        monImage.isUserInteractionEnabled = true
        monImage.addGestureRecognizer(monumentsTapGesture)

        let beachesTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterByBeaches))
        beachImage.isUserInteractionEnabled = true
        beachImage.addGestureRecognizer(beachesTapGesture)

        let shrinesTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterByShrines))
        shrineaImage.isUserInteractionEnabled = true
        shrineaImage.addGestureRecognizer(shrinesTapGesture)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(cityUpdated), name: Notification.Name("CityUpdated"), object: nil)
    }

    // MARK: - Notification Handling
    @objc private func cityUpdated() {
        loadInsights() // Reload insights when the city is updated
    }

    // MARK: - Data Loading
    private func loadInsights() {
        if let selectedCity = UserDefaults.standard.string(forKey: "selectedCity") {
            CityLabel.text = selectedCity
            fetchInsights(for: selectedCity)
        } else {
            CityLabel.text = "Select a city first"
            searchedInsites = []
            insightsCollectionView.reloadData()
            showEmptyState()
        }
    }

    private func fetchInsights(for city: String) {
        db.collection("insites")
            .whereField("city", isEqualTo: city)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Error fetching insights: \(error.localizedDescription)")
                    self.showEmptyState()
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("❌ No insights found for \(city)")
                    self.showEmptyState()
                    return
                }

                self.searchedInsites = documents.compactMap { document in
                    let data = document.data()
                    return Insite(
                        title: data["title"] as? String ?? "",
                        type: data["type"] as? String ?? "",
                        price: data["price"] as? String ?? "",
                        imageURL: data["imageURL"] as? String ?? "",
                        city: data["city"] as? String ?? ""
                    )
                }

                DispatchQueue.main.async {
                    self.insightsCollectionView.reloadData()
                    self.hideEmptyState()
                }
            }
    }

    // MARK: - Filtering
    @objc private func filterByAdventure() {
        filterCollectionView(by: "Adventure")
    }

    @objc private func filterByMonuments() {
        filterCollectionView(by: "Monuments")
    }

    @objc private func filterByBeaches() {
        filterCollectionView(by: "Beaches")
    }

    @objc private func filterByShrines() {
        filterCollectionView(by: "Shrines")
    }

    private func filterCollectionView(by type: String) {
        searchedInsites = searchedInsites.filter { $0.type == type }
        insightsCollectionView.reloadData()
    }

    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if searchText.isEmpty {
                self.loadInsights()
            } else {
                self.searchedInsites = self.searchedInsites.filter { $0.title.lowercased().contains(searchText.lowercased()) }
                self.insightsCollectionView.reloadData()
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadInsights()
    }

    // MARK: - Empty State
    private func showEmptyState() {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "No results found. Try another search!"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        insightsCollectionView.backgroundView = emptyStateLabel
    }

    private func hideEmptyState() {
        insightsCollectionView.backgroundView = nil
    }

    // MARK: - Refresh Control
    @objc private func refreshData() {
        loadInsights()
        insightsCollectionView.refreshControl?.endRefreshing()
    }

    // MARK: - Collection View Layout
    private func createCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 165, height: 226)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }
}

// MARK: - Collection View Delegates
extension CulturalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedInsites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightsCollectionViewCell", for: indexPath) as! InsightsCollectionViewCell
        let insight = searchedInsites[indexPath.item]
        cell.setup3(with: insight)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let insight = searchedInsites[indexPath.item]
            SDWebImagePrefetcher.shared.prefetchURLs([URL(string: insight.imageURL)].compactMap { $0 })
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSegueBeingPerformed { return }
        isSegueBeingPerformed = true
        let selectedInsite = searchedInsites[indexPath.item]
        performSegue(withIdentifier: "showHighlights", sender: selectedInsite)
    }
}

// MARK: - Navigation
extension CulturalViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHighlights", let destinationVC = segue.destination as? HighlightsViewController, let selectedInsite = sender as? Insite {
            destinationVC.selectedTitle = selectedInsite.title
        }
        isSegueBeingPerformed = false
    }
}
