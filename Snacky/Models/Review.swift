//
//  Reviews.swift
//  Snacky
//
//  Created by Harsh Verma on 16/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Firebase
class Review {
    
    var title: String
    var text: String
    var rating: Int
    var reviewUserID: String
    var reviewEmail: String
    var date: Date
    var documentID: String
    var dict: [String: Any] {
        let timeInterval = date.timeIntervalSince1970
        return ["title": title, "text": text, "rating": rating, "reviewUserID" :reviewUserID, "reviewEmail": reviewEmail, "date": timeInterval]
    }
    
    
    init(title: String, text: String, rating: Int, reviewUserID: String, reviewEmail: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewUserID = reviewUserID
        self.reviewEmail = reviewEmail
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() { // called whenever new review is created
        let reviewUserID = Auth.auth().currentUser?.uid ?? ""
        let revviewEmail = Auth.auth().currentUser?.email ?? "No Email"
        self.init(title: "", text: "", rating: 0, reviewUserID: reviewUserID, reviewEmail: revviewEmail, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let reviewUserID = dictionary["reviewUserID"] as! String? ?? ""
        let reviewEmail = dictionary["reviewEmail"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        
        
        self.init(title: title, text: text, rating: rating, reviewUserID: reviewUserID, reviewEmail: reviewEmail, date: date, documentID: documentID)
    }
    
    
    
    
    func saveData(spot: Spot, completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        
        //Dictionary Creation
        let dataToSave: [String: Any] = self.dict
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("🥵 Error: Adding Document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added Document:\(self.documentID)to spot: \(spot.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        }
        else { // save to existing documentID
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("🤬Error Updating Document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("😙😚Updated Document: \(self.documentID)in spot: \(spot.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        }
        
    }
    
    func deleteData(spot: Spot, completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("reviews").document(documentID).delete { (error) in
            if let ERRORs = error {
                print("Error:- Failed to delete document ID:- \(self.documentID) \(ERRORs.localizedDescription)")
                completion(false)
            }else {
                print("Yippie Deleted Doc From Database:- \(self.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        }
    }
    
    
}
