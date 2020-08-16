//
//  SpotDetailVC.swift
//  Snacky
//
//  Created by Harsh Verma on 12/06/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class SpotDetailVC: UIViewController {
    
    //MARK:- VARIABLES
    var spot: Spot!
    let regionDistance: CLLocationDegrees = 750.0
    var locationManager: CLLocationManager!
    var reviews: Reviews!
    var imagePickerController = UIImagePickerController()
    var photo: Photo!
    var photos: Photos!
    
    //MARK:- IBOUTLETS
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelBarBtn: UIBarButtonItem!
    @IBOutlet weak var saveBarBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hiding keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        imagePickerController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        getLocation()
        if spot == nil {
            spot = Spot()
        }else {
            disableTextEdit()
            cancelBarBtn.hide()
            saveBarBtn.hide()
            navigationController?.setToolbarHidden(true, animated: true)
        }
        reviews = Reviews()
        photos = Photos()
        setupmapView()
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if spot.documentID != "" {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        
        reviews.loadData(spot: spot) {
            self.tableView.reloadData()
            if self.reviews.reviewArray.count == 0 {
                self.ratingLabel.text = "-.-"
            }else {
                let sum = self.reviews.reviewArray.reduce(0) { $0 + $1.rating}
                var avgRat = Double(sum)/Double(self.reviews.reviewArray.count)
                avgRat = ((avgRat * 10).rounded()) / 10
                self.ratingLabel.text = "\(avgRat)"
            }
        }
        photos.loadData(spot: spot) {
            //CollectionView TODO
            self.collectionView.reloadData()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromUI()
        switch segue.identifier ?? "" {
        case "addReview":
            let nv = segue.destination as! UINavigationController
            let destination = nv.viewControllers.first as! ReviewTableViewController
            destination.spot = spot
        case "showReview":
            let destination = segue.destination as! ReviewTableViewController
            let indexpath = tableView.indexPathForSelectedRow!
            destination.review = reviews.reviewArray[indexpath.row]
            destination.spot = spot
        case "addPhoto":
            let nv = segue.destination as! UINavigationController
            let destination = nv.viewControllers.first as! PhotoViewController
            destination.spot = spot
            destination.photo = photo
        case "showPhoto":
            let destination = segue.destination as! PhotoViewController
            guard let sip = collectionView.indexPathsForSelectedItems?.first else {
                print("Error couldn't get selected collectionView item")
                return
            }
            destination.photo = photos.photoArray[sip.row]
            destination.spot = spot
            
        default:
            print("Should not happen")
        }
    }
    
    //MARK:- CUSTOM FUNCTIONS
    func setupmapView() {
        let region = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
    }
    
    
    func updateUserInterface() {
        nameTextField.text = spot.name
        addressTextField.text = spot.address
    }
    
    func updateFromUI() {
        spot.name = nameTextField.text!
        spot.address = addressTextField.text!
        updateMap()
    }
    
    func disableTextEdit() {
        nameTextField.isEnabled = false
        addressTextField.isEnabled = false
        nameTextField.backgroundColor = .clear
        addressTextField.backgroundColor = .clear
        nameTextField.borderStyle = .none
        addressTextField.borderStyle = .none
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(spot)
        mapView.setCenter(spot.coordinate, animated: true)
    }
    
    func leavingVC() {
        let isP = presentingViewController is UINavigationController
        if isP {
            dismiss(animated: true, completion: nil)
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func saveCancelAlert(title: String, message: String, segueID: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.spot.saveData { (success) in
                self.saveBarBtn.title = "Done"
                self.cancelBarBtn.hide()
                self.navigationController?.setToolbarHidden(true, animated: true)
                self.disableTextEdit()
                self.performSegue(withIdentifier: segueID, sender: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func camAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Access Camera", style: .default) { (_) in
            self.accessCamera()
        }
        let library = UIAlertAction(title: "Access Saved Pictures", style: .default) { (_) in
            self.accessLibrary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    
    //MARK:- IBACTIONS METHOD LIST
    @IBAction func nameFieldChanged(_ sender: UITextField) {
        let strip = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if strip != "" {
            saveBarBtn.isEnabled = true
        }else {
            saveBarBtn.isEnabled = false
        }
    }
    
    
    
    @IBAction func saveBtn(_ sender: UIBarButtonItem) {
        
        updateFromUI()
        spot.saveData { (success) in
            if success {
                self.leavingVC()
            }else {
                self.alert(title: "Error", message: "Maybe Some Error Occured")
            }
        }
        
    }
    
    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
        
        leavingVC()
    }
    
    @IBAction func photoBtnPressed(_ sender: UIButton) {
        if spot.documentID == "" {
            saveCancelAlert(title: "This Venue is not saved!", message: "Please save it before proceeding for reviews", segueID: "addPhoto")
        }
        else {
            camAlert(title: "Allow", message: "Be very sure!")
        }
    }
    
    
    
    @IBAction func locateBtn(_ sender: UIBarButtonItem) {
        let autoComplete = GMSAutocompleteViewController()
        autoComplete.delegate = self
        present(autoComplete, animated: true, completion: nil)
    }
    
    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        if spot.documentID == "" {
            saveCancelAlert(title: "This Venue is not saved!", message: "Please save it before proceeding for reviews", segueID: "addReview")
        }
        else {
            performSegue(withIdentifier: "addReview", sender: nil)
        }
        
    }
}

//MARK:- EXTENSIONS FOR GOOGLE AUTOPLACE COMPLETE
extension SpotDetailVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        spot.name = place.name ?? "Unknown Place"
        spot.address = place.formattedAddress ?? "Unknown Address"
        spot.coordinate = place.coordinate
        print(place.coordinate)
        updateUserInterface()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SpotDetailVC: CLLocationManagerDelegate {
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLoc = locations.last ?? CLLocation()
        print("Current Location is: \(currentLoc.coordinate.latitude), \(currentLoc.coordinate.longitude)")
        var name = ""
        var address = ""
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLoc) { (placemark, error) in
            if error != nil {
                print("Error: retrieveing place")
            }
            if placemark != nil {
                let placemark = placemark?.last
                name = placemark?.name ?? "Unknown Part"
                if let postal = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postal, style: .mailingAddress)
                }
            }
            else {
                print("Error retrieveing placemark")
                
            }
            if self.spot.name == "" && self.spot.address == "" {
                self.spot.name = name
                self.spot.address = address
                self.spot.coordinate = currentLoc.coordinate
            }
            self.mapView.userLocation.title = name
            self.mapView.userLocation.subtitle = address.replacingOccurrences(of: "\n", with: ", ")
            self.updateUserInterface()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription). Failed to get Dev Location")
    }
    
    
}

//MARK:- EXTENSION FOR TABLEVIEW PROTOCOLS
extension SpotDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! SpotReviewTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}

//MARK:- EXTENSION FOR IMAGE METHODS
extension SpotDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        photo = Photo()
        if let edit = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photo.image = edit
        }else if let original = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photo.image = original
        }
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "addPhoto", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func accessCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        }else {
            camAlert(title: "Camera Not Available", message: "Sorry!")
        }
    }
}
//MARK:- EXTENSION FOR COLLECTIONVIEW
extension SpotDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pcell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! SpotPhotoCollectionViewCell
        pcell.spot = spot
        pcell.photo = photos.photoArray[indexPath.row]
        return pcell
    }
    
    
}
