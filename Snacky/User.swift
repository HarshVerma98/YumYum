//
//  User.swift
//  Snacky
//
//  Created by Harsh Verma on 03/08/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Firebase

class AUser {
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
    
    convenience init(user: AUser) {
        let email = user.email ?? ""
        let displayName = user.displayName ?? ""
        let photoURL = (user.photoURL != nil ? "\(user.photoURL)" : "")
        self.init(email: email, displayName: displayName, photoURL: photoURL, since: Date(), documentID: user.uid)
    
    }
    
    convenience init(dictionary: [String: Any]) {
        <#statements#>
    }
    
}
