//
//  ViewController.swift
//  GitHubUsers
//
//  Created by Valentin Ozerov on 07/08/2019.
//  Copyright © 2019 Valentin Ozerov. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1000000
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UserTableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserTableViewCell
        
        if cell == nil {
            cell = UserTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "userCell")
        }
        
        let user = Users.shared[indexPath.row]
        cell?.user = user

        if let login = user.login {
            cell?.loginLabel.text = "Login: \(login)"
        }
        
        if let info = user.info {
            if let name = info.name {
                cell?.nameLabel.text = "\(name)"
            } else {
                cell?.nameLabel.text = "<unnamed>"
            }
            
            if let followers = info.followers {
                cell?.followersLabel.text = "Followers: \(followers)"
            } else {
                cell?.followersLabel.text = "Followers: unknown"
            }
            
            if let location = info.location {
                cell?.locationLabel.text = "Location: \(location)"
            } else {
                cell?.locationLabel.text = "Location: unknown"
            }
            
            cell?.starsLabel.text = "Stars: not found"
            if let starred = cell?.user?.stars {
                cell?.starsLabel.text = "Stars: \(starred)"
            }
        }
        
        if let data = user.avatar_data {
            cell?.avatarImageView.image = UIImage(data: data)
        } else {
            cell?.avatarImageView.image = nil
        }
        
        cell?.placeholderImageView.isHidden = true
        
        if !Users.shared.isUserInit(user: user) {
            cell?.startLoadingAnimation()
        }
        
        return cell!
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    var html_url :String!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        if let _html_url = currentCell.user?.html_url {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
            detailViewController.html_url = _html_url
            self.present(detailViewController, animated: true, completion: nil)
        }
    }
}

