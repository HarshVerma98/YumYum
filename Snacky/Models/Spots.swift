//
//  Spots.swift
//  Snacky
//
//  Created by Harsh Verma on 13/06/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Firebase

class Spots {
    var spotArray: [Spot] = []
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
            self.spotArray = []
            for doc in query!.documents {
                let sx = Spot(dictionary: doc.data())
                sx.documentID = doc.documentID
                self.spotArray.append(sx)
            }
            completed()
        }
    }
    
}
