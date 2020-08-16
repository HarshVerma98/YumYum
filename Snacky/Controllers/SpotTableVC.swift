//
//  SpotTableVC.swift
//  Snacky
//
//  Created by Harsh Verma on 12/06/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import CoreLocation

class SpotTableVC: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var currentlocation: CLLocation!
    var spot: Spot! {
        didSet {
            nameLabel.text = spot.name
            let roundedAvg = ((spot.averageRating * 10).rounded()) / 10
            ratingLabel.text = "Avg Rating: \(roundedAvg)"
            guard let currentLocation = currentlocation else {
                distanceLabel.text = "_._"
                return
            }
            let distMeter = spot.location.distance(from: currentLocation)
            let distMiles = ((distMeter * 0.00062137) * 10).rounded() / 10
            distanceLabel.text = "Distance: \(distMiles) Miles"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
