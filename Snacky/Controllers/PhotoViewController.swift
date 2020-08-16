//
//  PhotoViewController.swift
//  Snacky
//
//  Created by Harsh Verma on 25/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class PhotoViewController: UIViewController {
    
    private let dT: DateFormatter = {
        let date = DateFormatter()
        date.dateStyle = .medium
        date.timeStyle = .none
        return date
    }()
    
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var spot: Spot!
    var photo: Photo!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        guard spot != nil else {
            print("Error: No spot passed to PhotoViewController")
            return
        }
        if photo == nil {
            photo = Photo()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        postedByLabel.text = "BY:- \(photo.photoUserEmail)"
        dateLabel.text = "On:- \(dT.string(from: photo.date))"
        descriptionLabel.text = photo.description
        //imageView.image = photo.image
        
        
        if photo.documentID == "" {
            addBordertoEdit()
        }else {
            if photo.photoUserID == Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordertoEdit()
                self.navigationController?.setToolbarHidden(false, animated: true)
            }else {
                saveBarButton.hide()
                cancelBarButton.hide()
                postedByLabel.text = "Posted By:- \(photo.photoUserEmail)"
                
                descriptionLabel.isEditable = false
                descriptionLabel.backgroundColor = .white
            }
        }
        guard let url = URL(string: photo.photoURL) else {
            // Must be new image
            imageView.image = photo.image
            print("Failed URL")
            return
        }
        imageView.sd_imageTransition = .fade
        imageView.sd_imageTransition?.duration = 0.5
        imageView.sd_setImage(with: url)
    }
    
    func updateFromUI() {
        photo.description = descriptionLabel.text
        photo.image = imageView.image!
    }
    
    func addBordertoEdit() {
        descriptionLabel.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    
    func leavingVC() {
        let isPresent = presentingViewController is UINavigationController
        if isPresent {
            dismiss(animated: true, completion: nil)
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        updateFromUI()
        photo.saveData(spot: spot) { (success) in
            if success {
                self.leavingVC()
            }else {
                print("Error unwinding From Photo Review Controller Class")
            }
        }
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        leavingVC()
    }
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure you want to delete this image", message: "Be Wise", preferredStyle: .alert)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.imageView.image = UIImage()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    
}
