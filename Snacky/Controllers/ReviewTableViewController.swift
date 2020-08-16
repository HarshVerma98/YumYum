//
//  ReviewTableViewController.swift
//  Snacky
//
//  Created by Harsh Verma on 15/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import Firebase

private let dT: DateFormatter = {
    let date = DateFormatter()
    date.dateStyle = .medium
    date.timeStyle = .none
    return date
}()

class ReviewTableViewController: UITableViewController {
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var buttonsBackgroundView: UIView!
    @IBOutlet weak var reviewTitleField: UITextField!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var starButtonCollection: [UIButton]!
    var review: Review!
    var spot: Spot!
    var rating = 0 {
        didSet {
            for star in starButtonCollection {
                let imageName = (star.tag < rating ? "star.fill" : "star")
                star.setImage(UIImage(systemName: imageName), for: .normal)
                star.tintColor = (star.tag < rating ? .systemRed : .darkText)
            }
            print("New Rating is: \(rating)")
            review.rating = rating
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
              tap.cancelsTouchesInView = false
              self.view.addGestureRecognizer(tap)
        
        guard spot != nil else {
            print("Error: No spot passed to ReviewTableViewController")
            return
        }
        if review == nil {
            review = Review()
        }
        updateUI()
        
    }
    
    //MARK:- CUSTOM FUNCTIONS
    func updateUI() {
        nameLabel.text = spot.name
        addressLabel.text = spot.address
        reviewTitleField.text = review.title
        reviewTextView.text = review.text
        rating = review.rating
        reviewDateLabel.text = "Posted:- \(dT.string(from: review.date))"
        if review.documentID == "" {
            addBordertoEdit()
        }else {
            if review.reviewUserID == Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordertoEdit()
                deleteButton.isHidden = false
            }else {
                saveBarButton.hide()
                cancelBarButton.hide()
                postedByLabel.text = "Posted By:- \(review.reviewEmail)"
                for st in starButtonCollection {
                    st.backgroundColor = .white
                    st.isEnabled = false
                }
                reviewTitleField.isEnabled = false
                reviewTitleField.borderStyle = .none
                reviewTextView.isEditable = false
                reviewTitleField.backgroundColor = .white
                reviewTextView.backgroundColor = .white
            }
        }
    }
    
    func updateFromUI() {
        review.title = reviewTitleField.text!
        review.text = reviewTextView.text!
    }
    
    func addBordertoEdit() {
        reviewTitleField.addBorder(width: 0.5, radius: 5.0, color: .black)
        reviewTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
        buttonsBackgroundView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func leavingVC() {
        let isP = presentingViewController is UINavigationController
        if isP {
            dismiss(animated: true, completion: nil)
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:- IBACTION METHODS
    
    @IBAction func reviewTitleChanged(_ sender: UITextField) {
        let strip = reviewTitleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if strip != "" {
            saveBarButton.isEnabled = true
        }else {
            saveBarButton.isEnabled = false
        }
    }
    @IBAction func reviewTitleDonePressed(_ sender: UITextField) {
    }
    @IBAction func deleteButton(_ sender: UIButton) {
        review.deleteData(spot: spot) { (success) in
            if success {
                self.leavingVC()
            }else {
                print("Unsuccessful Deletion")
            }
        }
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        leavingVC()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        updateFromUI()
        review.saveData(spot: spot) { (SUCCESS) in
            if SUCCESS {
                self.leavingVC()
            }
            else {
                print("Review saving Error")
            }
        }
    }
    
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating = sender.tag + 1
    }
}
