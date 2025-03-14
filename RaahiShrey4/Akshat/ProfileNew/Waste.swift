//import UIKit
//import SDWebImage
//import FirebaseFirestore
//import FirebaseAuth
//import FirebaseStorage
////FFCEA2
//class CommunityViewController: UIViewController, UICollectionViewDelegate {
//    
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
//    @IBOutlet weak var collectionView: UICollectionView!
//    
//    
//    let viewModel = PostViewModel()
//    
//    let leaderboardViewModel = LeaderboardViewModel()
//    var leaderboardUsers: [LeaderboardUser] = []
//
//
//    
//    
//    override func viewDidLoad() {
//            super.viewDidLoad()
//            
//            // Set up collection view
//            collectionView.dataSource = self
//            collectionView.delegate = self
//            collectionView.collectionViewLayout = createCompositionalLayout(for: 0) // Default layout for "Your Following"
//            
//            // Configure segmented control
//            segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
//        
//        // Listen for profile updates
//            NotificationCenter.default.addObserver(self, selector: #selector(handleProfileUpdate), name: .profileUpdated, object: nil)
//
//        
//            // Fetching Posts
//        fetchPosts()
//        fetchLeaderboard()
//        
//        }
//    
//    @objc func handleProfileUpdate() {
//        // Refresh posts when the profile has changed
//        fetchPosts()
//    }
//    
//    // MARK: - Fetch Posts from Firestore
//    func fetchPosts() {
//            viewModel.fetchPosts {
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//            }
//        }
//    
//    // Fetch leaderboard function
//    func fetchLeaderboard() {
//        leaderboardViewModel.fetchLeaderboard {
//            self.leaderboardUsers = Array(self.leaderboardViewModel.topThreeUsers.prefix(3))
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        }
//    }
//       
//    
//    
//        @objc func segmentChanged(_ sender: UISegmentedControl) {
//            let selectedIndex = sender.selectedSegmentIndex
//            collectionView.collectionViewLayout = createCompositionalLayout(for: selectedIndex)
//            collectionView.reloadData()
//        }
//        
//        // Create compositional layout
//        func createCompositionalLayout(for segment: Int) -> UICollectionViewCompositionalLayout {
//            return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
//                switch segment {
//                        case 0: // "Your Following"
//                            return self.createYourFollowingSection(for: sectionIndex)
//                        case 1: // "Explore"
//                            return self.createExploreSection(for: sectionIndex)
//                        case 2: // "LeaderBoard"
//                            return self.createLeaderBoardSection(for: sectionIndex)
//                        default:
//                            return nil
//                        }
//            }
//        }
//        
//        // Layout for "Your Following"
//        func createYourFollowingSection(for section: Int) -> NSCollectionLayoutSection {
//            switch section {
//            case 0: // MakePostCell
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(135))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
//                
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(135))
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//                
//                return NSCollectionLayoutSection(group: group)
//            case 1: // PostCell
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(500))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
//                
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(500))
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//                
//                return NSCollectionLayoutSection(group: group)
//            default:
//                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))))
//            }
//        }
//    func createExploreSection(for section: Int) -> NSCollectionLayoutSection {
//        switch section {
//            
//        case 0: // TitleCell (Added this section for the leaderboard title)
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55)) // Reduced height
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15) // Reduced top and bottom padding
//            
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55)) // Reduced height
//            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//            
//            return NSCollectionLayoutSection(group: group)
//        
////        case 1: // Other Post (Vertical layout)
////            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(500))
////            let item = NSCollectionLayoutItem(layoutSize: itemSize)
////            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
////
////            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(500))
////            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
////
////            return NSCollectionLayoutSection(group: group)
//            
//        case 1: // TitleCell (Added this section for the leaderboard title)
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55)) // Reduced height
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15) // Reduced top and bottom padding
//            
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55)) // Reduced height
//            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//            
//            return NSCollectionLayoutSection(group: group)
//            
//        case 2: // Contact Designer (horizontal layout)
//            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(300), heightDimension: .absolute(170))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//            
//            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(170))
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//            
//            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .continuous
//            return section
//            
//        case 3: // TitleCell (Added this section for the leaderboard title)
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55)) // Reduced height
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15) // Reduced top and bottom padding
//            
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55)) // Reduced height
//            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//            
//            return NSCollectionLayoutSection(group: group)
//            
//        case 4: // design explore
//            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(230), heightDimension: .absolute(300))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//            
//            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(230), heightDimension: .absolute(300))
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//            
//            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .continuous
//            return section
//            
//        case 5: // TitleCell (Added this section for the leaderboard title)
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55)) // Reduced height
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15) // Reduced top and bottom padding
//            
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(55)) // Reduced height
//            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//            
//            return NSCollectionLayoutSection(group: group)
//            
//        case 6: // connect people
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//            
//            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(170))
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//            
//            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .continuous
//            return section
//            
//        default:
//            return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))))
//        }
//    }
//
//        
//        // Layout for "LeaderBoard"
//        func createLeaderBoardSection(for section: Int) -> NSCollectionLayoutSection {
//            switch section {
//            case 0: // Top 3 Users
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
//                
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//                
//                return NSCollectionLayoutSection(group: group)
//                
//            case 1: // TitleCell (Added this section for the leaderboard title)
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(110)) // Reduced height
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15) // Reduced top and bottom padding
//                
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(110)) // Reduced height
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//                
//                return NSCollectionLayoutSection(group: group)
//                
//            case 2: // Popular Designs
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70)) // Reduced height
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15) // Reduced top and bottom padding
//                
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70)) // Reduced height
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//                
//                return NSCollectionLayoutSection(group: group)
//                
//            default:
//                return NSCollectionLayoutSection(group: NSCollectionLayoutGroup(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0))))
//            }
//
//        }
//    }
//
//    // MARK: - UICollectionViewDataSource
//    extension CommunityViewController: UICollectionViewDataSource {
//        func numberOfSections(in collectionView: UICollectionView) -> Int {
//            switch segmentedControl.selectedSegmentIndex {
//            case 0:
//                return 2 // Your Following: 2 sections (1 for MakePostCell, 1 for PostCells)
//            case 1:
//                return 6 // Explore: 8 sections (4 title sections + 4 content sections)
//            case 2:
//                return 3 // LeaderBoard: 3 sections
//            default:
//                return 0
//            }
//        }
//
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            switch segmentedControl.selectedSegmentIndex {
//            case 0: // Your Following
//                return section == 0 ? 1 : viewModel.posts.count // 1 MakePostCell, 4 PostCells
//            case 1: // Explore
//                switch section {
////                case 0: return 1 // Title for "Post" category (PostTitleCollectionViewCell)
////                case 1: return 4 // Other Posts (4 items)
//                case 2: return 1 // Title for "Designers" category (ConDesTitleCollectionViewCell)
//                case 3: return 4 // Contact Designers (4 items)
//                case 4: return 1 // Title for "Fits" category (FitsTitleCollectionViewCell)
//                case 5: return 6 // Designs Explore (6 items)
//                case 6: return 1 // Title for "Connect People" category (ConPeopTitleCollectionViewCell)
//                case 7: return 5 // Connect People (5 items)
//                default: return 0
//                }
//            case 2: // LeaderBoard
//                switch section {
//                case 0: return 1 // Top 3 Users
//                case 1: return 1 // Title Cell for Leaderboard
//                case 2: return 3 // Popular Designs (3 items)
//                default: return 0
//                }
//            default:
//                return 0
//            }
//        }
//
//        
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            switch segmentedControl.selectedSegmentIndex {
//            case 0: // "Your Following"
//                if indexPath.section == 0 {
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MakePostCell", for: indexPath)
//                    if let makePostCell = cell as? MakePostCollectionViewCell {
//                        if let user = Datamodel.sampleUsers.first { // Safely unwrap 'user'
//                            makePostCell.configure(with: user)
//                            makePostCell.layer.cornerRadius = 10
//                            makePostCell.layer.borderColor = UIColor.lightGray.cgColor
//                            makePostCell.layer.borderWidth = 0.5
//                        } else {
//                            print("No user found in Datamodel.sampleUsers.")
//                        }
//                    }
//                    return cell
//                } else { // Post cell for "Your Following"
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! Posts2CollectionViewCell
//                            cell.configure(with: viewModel.posts[indexPath.item])
//                    
//                    let post = viewModel.posts[indexPath.item]  // Get the post from the viewModel
//                           
//                             // Configure cell with the post data
//                    cell.layer.cornerRadius = 10
//                    cell.layer.borderColor = UIColor.lightGray.cgColor
//                    cell.layer.borderWidth = 0.5
//                    return cell
//                }
//                
//        
//                
//            case 1: // "Explore"
//                switch indexPath.section {
//                case 0: // Title Cell
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostTitleCell", for: indexPath)
//                    return cell
//                    
////                case 1: // Other Posts
////                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherPostsCell", for: indexPath)
////                    if let otherPostsCell = cell as? OtherPostsCollectionViewCell {
////                        let post = Datamodel.CommunityPosts[indexPath.row] // Assuming indexPath.row for the actual posts
////                        otherPostsCell.configure(with: post)
////                    }
////                    return cell
//                
//                case 2: // Title Cell
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConDesTitleCell", for: indexPath)
//                    return cell
//                
//                case 3: // Contact Designers
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactDesignerCell", for: indexPath)
//                    if let contactCell = cell as? ContactDesignerCollectionViewCell {
//                        let designer = Datamodel.designers[indexPath.row]
//                        contactCell.configure(with: designer)
//                    }
//                    return cell
//                    
//                case 4: // Title Cell
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FitsTitleCell", for: indexPath)
//                    return cell
//                    
//                case 5: // Designs Explore
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DesignsExploreCell", for: indexPath)
//                    if let designsCell = cell as? DesignsExploreCollectionViewCell {
//                        let design = Datamodel.sampleDesigns[indexPath.row] // Assuming array of designs
//                        designsCell.configure(with: design)
//                    }
//                    return cell
//                    
//                case 6: // Title Cell
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConPeopTitleCell", for: indexPath)
//                    return cell
//                    
//                case 7: // Connect People
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectPeopleCell", for: indexPath)
//                    if let connectCell = cell as? ConnectPeopleCollectionViewCell {
//                        let person = Datamodel.connectPeopleData[indexPath.row] // Assuming array of people
//                        connectCell.configure(with: person)
//                    }
//                    return cell
//                    
//                default:
//                    return UICollectionViewCell()
//                }
//                
//                
//            case 2: // "LeaderBoard"
//                if indexPath.section == 0 {
//                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopUserCell", for: indexPath) as! LeaderBoard2CollectionViewCell
//                       
//                       // Pass the top 3 users from ViewModel
//                       cell.configure(with: leaderboardViewModel.topThreeUsers)
//                       
//                       return cell
//                   }
//                else if indexPath.section == 1 {
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleCell", for: indexPath)
//                    return cell
//                } else {
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankCell", for: indexPath)
//                    if let rankCell = cell as? RanksLeaderboardCollectionViewCell {
//                        let leaderboard = Datamodel.leaderboard[indexPath.row]
//                        rankCell.configure(with: leaderboard)
//                        
//                        rankCell.layer.cornerRadius = 10
//                        rankCell.layer.borderColor = UIColor.systemGray2.cgColor
//                        rankCell.layer.borderWidth = 0.3
//                        // Shadow
//                        rankCell.layer.shadowColor = UIColor.black.cgColor
//                        rankCell.layer.shadowOpacity = 0.2
//                        rankCell.layer.shadowOffset = CGSize(width: 0, height: 2)
//                        rankCell.layer.shadowRadius = 4
//                    }
//                    return cell
//                }
//                
//            default:
//                return UICollectionViewCell()
//            }
//        }
//
//    }
