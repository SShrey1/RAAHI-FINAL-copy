//
//  ViewController.swift
//  RaahiShrey
//
//  Created by user@59 on 23/10/24.
//

import UIKit
import AuthenticationServices
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

class LoginViewController: UIViewController {

    @IBOutlet weak var LetsLabel: UILabel!
    @IBOutlet weak var DetailsLabel: UILabel!
    @IBOutlet weak var UserText: UITextField!
    @IBOutlet weak var SignUpText: UITextField!
    @IBOutlet weak var PasswordText: UITextField!
    @IBOutlet weak var SignUpButton: UIButton!
    @IBOutlet weak var InstantLabel: UILabel!
    @IBOutlet weak var GoogleButton: UIButton!
    @IBOutlet weak var AlreadyText: UILabel!
    @IBOutlet weak var SignInButton: UIButton!
    
    @IBOutlet weak var googleImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Google button with logo and text
        setupGoogleButton()
        
        // Set up sign-up button
        SignUpButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        // Configure Google Sign-In
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Missing client id")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        // Add target for Google Sign-In button
        GoogleButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        
        // Check if the user is already signed in
        checkUserSignInStatus()
        
        // Set up Apple Sign-In button
        setUpAppleSignInButton()
    }
    
    // MARK: - Google Button Setup
    private func setupGoogleButton() {
        // Create an attributed string with the Google logo and text
        let googleLogo = UIImage(named: "gg")  // Ensure "Google" is the name of your Google logo image in assets
        let attachment = NSTextAttachment()
        attachment.image = googleLogo
        attachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)  // Adjust bounds to align the image properly
        
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(string: "  Sign in with Google"))  // Add space and text
        
        // Set the attributed string to the button
        GoogleButton.setAttributedTitle(attributedString, for: .normal)
        
        // Customize button appearance
        GoogleButton.backgroundColor = UIColor.white
        GoogleButton.setTitleColor(.black, for: .normal)
        GoogleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        GoogleButton.layer.cornerRadius = 8
        GoogleButton.layer.borderWidth = 1
        GoogleButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    // MARK: - Email Sign-In
    @objc private func didTapButton() {
        print("Login Button tapped")
        guard let email = SignUpText.text, !email.isEmpty,
              let password = PasswordText.text, !password.isEmpty else {
            print("Missing field data ")
            return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                strongSelf.showCreateAccount(email: email, password: password)
                return
            }
            print("You have signed In")
            
            strongSelf.SignUpText.isHidden = true
            strongSelf.PasswordText.isHidden = true
            strongSelf.showHomeScreen()
        })
    }
    
    func showCreateAccount(email: String, password: String) {
        let alert = UIAlertController(title: "Create Account", message: "Would you like to create an account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
                guard let strongSelf = self else {
                    return
                }
                guard error == nil else {
                    print("Account creation failed")
                    return
                }
                print("You have signed In")
                
                strongSelf.SignUpText.isHidden = true
                strongSelf.PasswordText.isHidden = true
                strongSelf.showHomeScreen()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        present(alert, animated: true)
    }
    
    // MARK: - Google Sign-In
    @objc func signInWithGoogle() {
        print("Sign In Button Tapped")
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            guard let user = signInResult?.user, let idToken = user.idToken?.tokenString else {
                print("No User or id token")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    return
                }
                
                print("User signed in: \(authResult?.user.uid ?? "")")
                self.showHomeScreen()
            }
        }
    }
    
    // MARK: - Check User Sign-In Status
    func checkUserSignInStatus() {
        if Auth.auth().currentUser != nil {
            showHomeScreen()
        }
    }
    
    // MARK: - Navigate to Home Screen
    func showHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        self.view.window?.rootViewController = tabBarController
        self.view.window?.makeKeyAndVisible()
    }
    
    // MARK: - Apple Sign-In
    func setUpAppleSignInButton() {
        let applebtn = ASAuthorizationAppleIDButton()
        applebtn.frame = CGRect(x: 20, y: (UIScreen.main.bounds.size.height - 350), width: (UIScreen.main.bounds.size.width - 40), height: 50)
        applebtn.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        self.view.addSubview(applebtn)
    }
    
    @objc func appleSignInTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Sign-In Button Action
    @IBAction func SignInTapped(_ sender: Any) {
        performSegue(withIdentifier: "SignIn", sender: sender)
    }
}

// MARK: - Apple Sign-In Delegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            print(credentials.user)
            print(credentials.fullName?.givenName ?? "No Given Name")
            print(credentials.fullName?.familyName ?? "No Family Name")
        case let credentials as ASPasswordCredential:
            print(credentials.password)
        default:
            let alert = UIAlertController(title: "Apple SignIn", message: "Something went wrong with your Apple SignIn", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Apple Sign-In Presentation Context
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
