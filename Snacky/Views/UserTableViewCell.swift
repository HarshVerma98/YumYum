//
//  UserTableViewCell.swift
//  Snacky
//
//  Created by Harsh Verma on 03/08/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import SDWebImage

private let dT: DateFormatter = {
    let date = DateFormatter()
    date.dateStyle = .medium
    date.timeStyle = .none
    return date
}()

class UserTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var sinceLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var suser: SUser! {
        didSet {
            displayName.text = suser.displayName
            emailLabel.text = suser.email
            sinceLabel.text = "\(dT.string(from: suser.since))"
            userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
            userImage.clipsToBounds = true
            guard let url = URL(string: suser.photoURL) else {
                userImage.image = UIImage(systemName: "person.crop.circle")
                return
            }
            userImage.sd_imageTransition = .fade
            userImage.sd_imageTransition?.duration = 0.1
            userImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle"))
        }
    }

}
