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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //signup button
        SignUpButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Missing client id")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        GoogleButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        GoogleButton.backgroundColor = UIColor.white
        
        checkUserSignInStatus()
        setUpAppleSignInButton()
    }
    
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
            
            
            
        })
        
    }
    
    
    func showCreateAccount(email : String, password : String) {
        
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
                
                
            })
            
            
            
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
        }))
        
        present(alert, animated : true)
    }
    
    
    
    
    // Google Sign In
    
    @objc func signInWithGoogle() {
        print("Sign In Button Tapped")
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            if let error = error {
                print("Error signing in : \(error.localizedDescription)")
                return
            }
            
            guard let user = signInResult?.user, let idToken = user.idToken?.tokenString else {
                print("No User or id token")
                return
                
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error authenticating : \(error.localizedDescription)")
                    return
                }
                
                print("User signed in : \(authResult?.user.uid ?? "")")
                self.showHomeScreen()
                
            }
            
            
            }
        }
    
    func checkUserSignInStatus() {
        if Auth.auth().currentUser != nil {
            showHomeScreen()
        }
    }
    
    func showHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        self.view.window?.rootViewController = tabBarController
        self.view.window?.makeKeyAndVisible()
    }

    
    // Apple Sign In
    
    func setUpAppleSignInButton(){
        let applebtn = ASAuthorizationAppleIDButton()
        applebtn.frame = CGRect(x: 20, y: (UIScreen.main.bounds.size.height - 350), width: (UIScreen.main.bounds.size.width - 40), height: 50)
        applebtn.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        
        self.view.addSubview(applebtn)
        
    }
    
    @objc func appleSignInTapped(){
       
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        
    }
    

    @IBAction func SignInTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "SignIn", sender: sender)
        
        
    }
    
}

extension LoginViewController : ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            print(credentials.user)
            print(credentials.fullName?.givenName!)
            print(credentials.fullName?.familyName!)
        case let credentials as ASPasswordCredential :
            print(credentials.password)
            
        default:
            let alert = UIAlertController(title: "Apple SignIn", message: "Something went wrong with your Apple SignIn", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding{
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
}
