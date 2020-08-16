//
//  User.swift
//  Snacky
//
//  Created by Harsh Verma on 03/08/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Firebase

class SUser {
    var email: String
    var displayName: String
    var photoURL: String
    var since: Date
    var documentID: String
    
    var dict: [String: Any] {
        let timeInt = since.timeIntervalSince1970
        return["email": email, "displayName": displayName, "photoURL": photoURL, "since": timeInt]
    }
    //Base Initializer
    init(email: String, displayName: String, photoURL: String, since: Date, documentID: String ) {
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.since = since
        self.documentID = documentID
    }
    
    //Convenience Initializer
    
    convenience init(user: User) {
        let email = user.email ?? ""
        let displayName = user.displayName ?? ""
        let photoURL = (user.photoURL != nil ? "\(user.photoURL!)" : "")
        self.init(email: email, displayName: displayName, photoURL: photoURL, since: Date(), documentID: user.uid)
        
    }
    
    convenience init(dictionary: [String: Any]) {
        let email = dictionary["email"] as! String? ?? ""
        let displayName = dictionary["displayName"] as! String? ?? ""
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        let timeInterval = dictionary["since"] as! TimeInterval? ?? TimeInterval()
        let since = Date(timeIntervalSince1970: timeInterval)
        self.init(email: email, displayName: displayName, photoURL: photoURL, since: since, documentID: "")
        
    }
    
    
    func saveUser(completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        let userREF = db.collection("users").document(documentID)
        userREF.getDocument { (doc, error) in
            guard error == nil else {
                print("Can't access document for user: \(self.documentID)")
                return completion(false)
            }
            guard doc?.exists == false else {
                print("Document already exists")
                return completion(true)
            }
            
            let DS: [String: Any] = self.dict
            db.collection("users").document(self.documentID).setData(DS) { (error) in
                guard error == nil else {
                    print("Error saving data")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
    
}
