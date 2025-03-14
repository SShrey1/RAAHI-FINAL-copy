import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth

class EditProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Components
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.addTarget(self, action: #selector(changeProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        return button
    }()
    
    let sectionTitles = ["Personal Information", "Location"]
    var sectionData: [String: [String: String]] = [
        "Personal Information": ["Email": "shreya14@gmail.com", "Name": "Shreya Agrawal", "Date of Birth": "01/01/1990", "Phone": "123-456-7890"],
        "Location": ["Country/Region": "India"]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        loadUserData()  // Load saved user data
        loadProfileImage()  // Load saved profile image
        setupTableHeaderView()
        setupFooterView()
    }

    // MARK: - Setup Profile Header
    private func setupTableHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        headerView.addSubview(profileImageView)
        headerView.addSubview(changePhotoButton)
        
        profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        changePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10).isActive = true
        changePhotoButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Setup Sign Out Button in Footer
    private func setupFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        footerView.addSubview(signOutButton)
        
        NSLayoutConstraint.activate([
            signOutButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            signOutButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            signOutButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        tableView.tableFooterView = footerView
    }

    // MARK: - TableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData[sectionTitles[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let section = sectionTitles[indexPath.section]
        let keys = Array(sectionData[section]!.keys)
        let key = keys[indexPath.row]
        
        cell.textLabel?.text = "\(key): \(sectionData[section]![key]!)"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionTitles[indexPath.section]
        let keys = Array(sectionData[section]!.keys)
        let key = keys[indexPath.row]

        // Allow editing all fields
        presentEditAlert(for: key)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func presentEditAlert(for field: String) {
        let alert = UIAlertController(title: "Edit \(field)", message: "Enter your new \(field.lowercased())", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.sectionData["Personal Information"]?[field] ?? self.sectionData["Location"]?[field]
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let newValue = alert.textFields?.first?.text, !newValue.isEmpty {
                if self.sectionData["Personal Information"]?[field] != nil {
                    self.sectionData["Personal Information"]?[field] = newValue
                } else if self.sectionData["Location"]?[field] != nil {
                    self.sectionData["Location"]?[field] = newValue
                }
                self.saveUserData() // Save to UserDefaults
                self.tableView.reloadData()
                
                // Post notification to update ProfileViewController1
                if field == "Name" {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ProfileNameUpdated"),
                        object: nil,
                        userInfo: ["name": newValue]
                    )
                    print("Notification posted with new name: \(newValue)")
                }
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }

    // MARK: - Change Profile Photo
    @objc private func changeProfilePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
            saveProfileImage(image: selectedImage) // Save image
            
            // Post notification with the new image data
            if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ProfileImageUpdated"),
                    object: nil,
                    userInfo: ["imageData": imageData]
                )
            }
        }
        picker.dismiss(animated: true)
    }

    // MARK: - Sign Out
    @objc func handleSignOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            print("Signed out")
            
            navigateToLogin()
        } catch let signoutError as NSError {
            print("Error signing out: \(signoutError)")
        }
    }

    func navigateToLogin() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let navController = UINavigationController(rootViewController: loginVC)
        
        sceneDelegate.window?.rootViewController = navController
        sceneDelegate.window?.makeKeyAndVisible()
    }

    // MARK: - Persistent Data Using UserDefaults
    private func loadUserData() {
        if let savedData = UserDefaults.standard.dictionary(forKey: "UserProfile") as? [String: [String: String]] {
            sectionData = savedData
        }
    }

    private func saveUserData() {
        UserDefaults.standard.setValue(sectionData, forKey: "UserProfile")
        print("User data saved: \(sectionData)")
    }
    
    // MARK: - Save and Load Profile Image
    private func saveProfileImage(image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
    }

    private func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let savedImage = UIImage(data: imageData) {
            profileImageView.image = savedImage
        }
    }
}
