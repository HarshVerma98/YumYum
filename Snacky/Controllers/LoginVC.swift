//
//  LoginVC.swift
//  Snacky
//
//  Created by Harsh Verma on 12/06/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import FirebaseUI
class LoginVC: UIViewController {
    
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        if authUI.auth?.currentUser == nil { // user has not signed in
            self.authUI.providers = providers // show providers named after let providers: above
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } else { // user is already logged in
            guard let currentUser = authUI.auth?.currentUser else {
                print("Error getting current user")
                return
            }
           let X = SUser(user: currentUser)
            X.saveUser { (success) in
                if success {
                    self.performSegue(withIdentifier: "FSS", sender: nil)
                }else {
                    print("Failed")
                }
            }
           
        }
    }
    
    func signOut() {
        do {
            try authUI!.signOut()
        } catch {
            print("😡 ERROR: couldn't sign out")
            performSegue(withIdentifier: "FSS", sender: nil)
        }
    }
    
    @IBAction func unwindSignOutPressed(segue: UIStoryboardSegue) {
        if segue.identifier == "SignOutUnwind" {
            signOut()
        }
    }
}

extension LoginVC: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard error == nil else {
            print("😡 ERROR: during signin \(error!.localizedDescription)")
            return
        }
        if let user = user {
            print("📝 We signed in with user \(user.email ?? "unknown e-mail")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let marginInsets: CGFloat = 16.0 // amount to indent UIImageView on each side
        let topSafeArea = self.view.safeAreaInsets.top
        
        // Create an instance of the FirebaseAuth login view controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        // Set background color to white
        loginViewController.view.backgroundColor = UIColor.white
        loginViewController.view.subviews[0].backgroundColor = UIColor.clear
        loginViewController.view.subviews[0].subviews[0].backgroundColor = UIColor.clear
        
        // Create a frame for a UIImageView to hold our logo
        let x = marginInsets
        let y = marginInsets + topSafeArea
        let width = self.view.frame.width - (marginInsets * 2)
        let height = loginViewController.view.subviews[0].frame.height - (topSafeArea) - (marginInsets * 2)
        
        let logoFrame = CGRect(x: x, y: y, width: width, height: height)
        
        // Create the UIImageView using the frame created above & add the "logo" image
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit // Set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView) // Add ImageView to the login controller's main view
        return loginViewController
    }
}
