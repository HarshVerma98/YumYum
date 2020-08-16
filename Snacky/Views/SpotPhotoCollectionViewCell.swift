//
//  SpotPhotoCollectionViewCell.swift
//  Snacky
//
//  Created by Harsh Verma on 29/07/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import SDWebImage
class SpotPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var spot: Spot!
    var photo: Photo! {
        didSet {
            if let url = URL(string: self.photo.photoURL) {
                self.imageView.sd_imageTransition = .fade
                self.imageView.sd_imageTransition?.duration = 0.3
                self.imageView.sd_setImage(with: url)
            }else {
                print("URL not working\(self.photo.photoURL)")
                self.photo.loadImage(spot: self.spot) { (success) in
                    self.photo.saveData(spot: self.spot) { (success) in
                        print("Image updated with URL:- \(self.photo.photoURL)")
                    }
                }
            }
            
        }
    }
}
