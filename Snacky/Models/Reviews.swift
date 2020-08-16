//
//  Reviews1.swift
//  Snacky
//
//  Created by Harsh Verma on 16/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray: [Review] = []
    var db: Firestore!

    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping() -> ()) {
        guard spot.documentID != "" else {
            return
        }
        db.collection("spots").document(spot.documentID).collection("reviews").addSnapshotListener { (snap, error) in
            guard error == nil else {
                print("Error Adding snapshot listener: \(error!.localizedDescription)")
                completed()
                return
            }
            self.reviewArray = [] // remove existing array since new data will be loaded
            for document in snap!.documents {
                let Rev = Review(dictionary: document.data())
                Rev.documentID = document.documentID
                self.reviewArray.append(Rev)
            }
            completed()
        }
        
    }
    
    
}
