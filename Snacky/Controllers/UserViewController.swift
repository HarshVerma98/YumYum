//
//  UserViewController.swift
//  Snacky
//
//  Created by Harsh Verma on 03/08/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    var suser: SUsers!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        suser = SUsers()
        suser.loader {
            self.tableView.reloadData()
        }
    }
}
extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suser.userArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        cell.suser = suser.userArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
