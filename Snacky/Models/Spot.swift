//
//  Spot.swift
//  Snacky
//
//  Created by Harsh Verma on 13/06/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class Spot: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var name: String
    var address: String
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    var dict: [String: Any] {
        return ["name": name, "address": address, "latitude": latitude, "longitude": longitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return address
    }
    
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    override convenience init() {
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longitude = dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        
        self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
        
    }
    
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        guard let post = Auth.auth().currentUser?.uid else {
            print("Error no PostingUSERID")
            return completion(false)
        }
        self.postingUserID = post
        let DS: [String: Any] = self.dict
        if self.documentID == "" {
            var RG: DocumentReference? = nil
            RG = db.collection("spots").addDocument(data: DS) { (error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return completion(false)
                }
                self.documentID = RG!.documentID
                print("Added Doc \(self.documentID)")
                completion(true)
            }
        }else {
            let R = db.collection("spots").document(self.documentID)
            R.setData(DS) { (error) in
                guard error == nil else {
                    print("Error Updating \(self.documentID)")
                    return completion(false)
                }
                print("Updated Document: \(self.documentID)")
                completion(true)
            }
        }
    }
    
    func updateAverageRating(completed: @escaping() -> ()) {
        let db = Firestore.firestore()
        let reviewRef = db.collection("spots").document(self.documentID).collection("reviews")
        reviewRef.getDocuments { (snap, error) in
            guard error == nil else {
                print("failed tp get QuerySnapshot")
                return completed()
            }
            var totalRat = 0.0
            for dox in snap!.documents {
                let revDict = dox.data()
                let rating = revDict["rating"] as! Int? ?? 0
                totalRat = totalRat + Double(rating)
            }
            self.averageRating = totalRat
            self.numberOfReviews = snap!.count
            let DS = self.dict
            let spotREF = db.collection("spots").document(self.documentID)
            spotREF.setData(DS) { (error) in
                if let EX = error {
                    print("ERROR UPDATING document \(self.documentID) after changing averageReview")
                    completed()
                }else {
                    print("New Average Rating \(self.averageRating)")
                    completed()
                }
            }
        }
    }
    
}
