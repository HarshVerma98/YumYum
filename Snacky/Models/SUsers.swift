//
//  SUsers.swift
//  Snacky
//
//  Created by Harsh Verma on 03/08/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Firebase

class SUsers {
    var userArray: [SUser] = []
    var db: Firestore!
    
    
    
    init() {
        db = Firestore.firestore()
    }
    
    
    func loader(completed: @escaping () -> ()) {
        db.collection("spots").addSnapshotListener { (query, error) in
            guard error == nil else {
                print("Error Adding Snapshot \(error!.localizedDescription)")
                return completed()
            }
            self.userArray = []
            for doc in query!.documents {
                let sx = SUser(dictionary: doc.data())
                sx.documentID = doc.documentID
                self.userArray.append(sx)
            }
            completed()
        }
    }
    
}

