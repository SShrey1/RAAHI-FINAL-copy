//
//  AppDelegate.swift
//  RaahiShrey4
//
//  Created by user@59 on 05/11/24.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        checkUserSignInStatus()
        
        return true
    }
    
    func application(_ app : UIApplication, open url : URL, options : [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func checkUserSignInStatus() {
        if let user = Auth.auth().currentUser{
            print("User is already Signed in : \(user.uid)")
            showHomeScreen()
        } else {
            print("No user is signed in")
            showLoginScreen()
        }
    }
    
    func showHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
    }
    
    func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

