//
//  SpotReviewTableViewCell.swift
//  Snacky
//
//  Created by Harsh Verma on 21/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit

class SpotReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
    @IBOutlet var starCollection: [UIImageView]!
    var review: Review! {
        didSet {
            reviewTitleLabel.text = review.title
            reviewTextLabel.text = review.text
            
            for starimg in starCollection {
                let imageName = (starimg.tag < review.rating ? "star.fill" : "star")
                starimg.image = UIImage(systemName: imageName)
                starimg.tintColor = (starimg.tag < review.rating ? .systemRed : .darkText)
            }
        }
    }
    
}
