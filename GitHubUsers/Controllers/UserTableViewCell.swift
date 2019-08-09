//
//  UserTableViewCell.swift
//  GitHubUsers
//
//  Created by Valentin Ozerov on 07/08/2019.
//  Copyright © 2019 Valentin Ozerov. All rights reserved.
//

let placeHolderAvatarURL = "https://cdn3.iconfinder.com/data/icons/free-social-icons/67/github_circle_color-512.png"

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(_userListDownloaded), name: NSNotification.Name("userListDownloaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_updateUserInfo(_:)), name: NSNotification.Name("updateUserInfo"), object: nil)
    }
    
    func startLoadingAnimation() {
        avatarImageView.image = nil
        nameLabel.text = ""
        loginLabel.text = ""
        locationLabel.text = ""
        followersLabel.text = ""
        starsLabel.text = ""
        
        placeholderImageView.isHidden = false
        placeholderImageView.alpha = 1
        UIView.animate(withDuration: 1.0,
                       delay: 1.0,
                       options: [.curveEaseInOut, .repeat, .autoreverse],
                       animations: {
                            UIView.setAnimationRepeatCount(1000000)
                            self.placeholderImageView.alpha = 0 },
                       completion:  nil
            )
        
    }
    
    @objc func _userListDownloaded() {
        guard Users.shared.isUserInit(user: user) else { return }
        showUserInfo()
    }
    
    @objc func _updateUserInfo(_ notification: NSNotification) {
        if let login = notification.userInfo?["login"] as? String {
            if login == user?.login
                && Users.shared.isUserInit(user: user) {
                showUserInfo()
            }
        }
    }
    
    func showUserInfo() {
        DispatchQueue.main.async {
            self.placeholderImageView.isHidden = true
            if let avatar_date = self.user?.avatar_data {
                self.avatarImageView.image = UIImage(data: avatar_date)
            }
            self.loginLabel.text = "Login: \(String(self.user!.login!))"
            if let info = self.user?.info {
                if let name = info.name {
                    self.nameLabel.text = "\(name)"
                } else {
                    self.nameLabel.text = "<unnamed>"
                }
                
                if let followers = info.followers {
                    self.followersLabel.text = "Followers: \(followers)"
                } else {
                    self.followersLabel.text = "Followers: unknown"
                }
                
                if let location = info.location {
                    self.locationLabel.text = "Location: \(location)"
                } else {
                    self.locationLabel.text = "Location: unknown"
                }
            }
            
            self.starsLabel.text = "Stars: not found"
            if let starred = self.user?.stars {
                self.starsLabel.text = "Stars: \(starred)"
            }
        }
    }
}


