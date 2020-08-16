//
//  SpotListVC.swift
//  Snacky
//
//  Created by Harsh Verma on 12/06/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import CoreLocation

class SpotListVC: UIViewController {
    
    var spots: Spots!
    var locationManager: CLLocationManager!
    var currentlocation: CLLocation!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spots = Spots()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        segment()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
        getLocation()
        spots.loader {
            self.sortSegmentOrder()
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let dvc = segue.destination as! SpotDetailVC
            let selection = tableView.indexPathForSelectedRow!
            dvc.spot = spots.spotArray[selection.row]
        }
    }
    
    func segment() {
        
        let or = [NSAttributedString.Key.foregroundColor : UIColor(named: "Color") ?? UIColor.red]
        let wh = [NSAttributedString.Key.foregroundColor : UIColor.white]
        sortSegment.setTitleTextAttributes(or, for: .selected)
        sortSegment.setTitleTextAttributes(wh, for: .normal)
        sortSegment.layer.borderColor = UIColor.white.cgColor
        sortSegment.layer.borderWidth = 1.0
        
        
    }
    
    func sortSegmentOrder() {
        switch sortSegment.selectedSegmentIndex  {
        case 0:
            spots.spotArray.sort(by: {$0.name < $1.name})
        case 1:
            print("Error Fixing Needed")
//            spots.spotArray.sort(by: {$0.location.distance(from: currentlocation) < $1.location.distance(from: currentlocation)})
        case 2:
            spots.spotArray.sort(by: {$0.averageRating > $1.averageRating})
        default:
            print("Not Allowed Here")
        }
        tableView.reloadData()
    }
    
    @IBAction func userBtn(_ sender: UIBarButtonItem) {
    }
    
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortSegmentOrder()
    }
}

extension SpotListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpotTableVC
        if let currentLocation = currentlocation {
            cell.currentlocation = currentLocation
        }
        //        cell.nameLabel.text = spots.spotArray[indexPath.row].name
        cell.spot = spots.spotArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
}
extension SpotListVC: CLLocationManagerDelegate {
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentlocation = locations.last
        print("Current Location is: \(currentlocation.coordinate.latitude) \(currentlocation.coordinate.longitude)")
        sortSegmentOrder()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
