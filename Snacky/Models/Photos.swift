//
//  Photos.swift
//  Snacky
//
//  Created by Harsh Verma on 29/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    var db: Firestore!

    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping() -> ()) {
        guard spot.documentID != "" else {
            return
        }
        db.collection("spots").document(spot.documentID).collection("photos").addSnapshotListener { (snap, error) in
            guard error == nil else {
                print("Error Adding snapshot listener: \(error!.localizedDescription)")
                completed()
                return
            }
            self.photoArray = [] // remove existing array since new data will be loaded
            for document in snap!.documents {
                let phooto = Photo(dictionary: document.data())
                phooto.documentID = document.documentID
                self.photoArray.append(phooto)
            }
            completed()
        }
        
    }
    
    
}
