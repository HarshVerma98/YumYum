//
//  Photo.swift
//  Snacky
//
//  Created by Harsh Verma on 25/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//


import UIKit
import SDWebImage
import Firebase
class Photo {
    var image: UIImage
    var description: String
    var photoUserID: String
    var photoUserEmail: String
    var date: Date
    var photoURL: String
    var documentID: String
    var dict: [String: Any] {
        let timeInterval = date.timeIntervalSince1970
        return ["description": description, "photoUserID": photoUserID, "photoUserEmail": photoUserEmail, "date": timeInterval, "photoURL": photoURL]
        
    }
    
    init(image: UIImage, description: String, photoUserID: String, photoUserEmail: String, date: Date,photoURL: String, documentID: String) {
        self.image = image
        self.description = description
        self.photoUserID = photoUserID
        self.photoUserEmail = photoUserEmail
        self.date = date
        self.photoURL = photoURL
        self.documentID = documentID
    }
    
    
    convenience init() { // called whenever new review is created
        let photoUSERID = Auth.auth().currentUser?.uid ?? ""
        let photoUSEREMAIL = Auth.auth().currentUser?.email ?? "No Email"
        self.init(image: UIImage(), description: "", photoUserID: photoUSERID, photoUserEmail: photoUSEREMAIL, date: Date() , photoURL: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        self.init(image: UIImage(), description: description, photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: date , photoURL: photoURL, documentID: "")
        
    }
    
    func saveData(spot: Spot, completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("Error could not convert photo to Data")
            return
        }
        
        // Metadata creation
        let uploadMeta = StorageMetadata()
        uploadMeta.contentType = "image/jpeg"
        
        //creating file name if essential
        if documentID == "" {
            documentID = UUID().uuidString
        }
        
        // Storage Reference creation to upload file in folder
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        
        //uploading task creation
        let uploadTask = storageRef.putData(photoData, metadata: uploadMeta) { (meta, error) in
            if let er = error {
                print("ERROR: upload for Ref \(uploadMeta)failed \(er.localizedDescription)")
            }
        }
        uploadTask.observe(.success) { (snap) in
            print("Upload to Firebase Storage successfull")
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("Error")
                    return completion(false)
                }
                guard let url = url else {
                    print("Error URL was nil")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                let DataSave: [String: Any] = self.dict
                let REFER =  db.collection("spots").document(spot.documentID).collection("photos").document(self.documentID)
                REFER.setData(DataSave) { (error) in
                    guard error == nil else {
                        print("Updating Document Failed \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("Updated document: \(self.documentID)")
                    completion(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { (snap) in
            if let error = snap.error {
                print("Upload task for file \(self.documentID)failed in spot \(spot.documentID) with error \(error.localizedDescription)")
            }
            completion(false)
        }
    }
    
    
    func loadImage(spot: Spot, completion: @escaping(Bool) -> ()) {
        guard spot.documentID != "" else {
            print("Did not pass any valid spot in loadImage")
            return
        }
        let storage = Storage.storage()
        let strref = storage.reference().child(spot.documentID).child(documentID)
        strref.getData(maxSize: 25*1024*1024) { (data, error) in
            if let ER = error {
                print("Error reading data from reference \(strref) error = \(ER.localizedDescription)")
                return completion(false)
            }
            else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
    
    
}
