//
//  User.swift
//  GitHubUsers
//
//  Created by Valentin Ozerov on 07/08/2019.
//  Copyright © 2019 Valentin Ozerov. All rights reserved.
//
/* Example:
{
    "login": "simonjefford",
    "id": 136,
    "node_id": "MDQ6VXNlcjEzNg==",
    "avatar_url": "https://avatars2.githubusercontent.com/u/136?v=4",
    "gravatar_id": "",
    "url": "https://api.github.com/users/simonjefford",
    "html_url": "https://github.com/simonjefford",
    "followers_url": "https://api.github.com/users/simonjefford/followers",
    "following_url": "https://api.github.com/users/simonjefford/following{/other_user}",
    "gists_url": "https://api.github.com/users/simonjefford/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/simonjefford/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/simonjefford/subscriptions",
    "organizations_url": "https://api.github.com/users/simonjefford/orgs",
    "repos_url": "https://api.github.com/users/simonjefford/repos",
    "events_url": "https://api.github.com/users/simonjefford/events{/privacy}",
    "received_events_url": "https://api.github.com/users/simonjefford/received_events",
    "type": "User",
    "site_admin": false
} */

import Foundation

class GHUItem {
    private var downloadTaskHashValue: Int?
}

final class UserInfo: Codable {
    var name: String?
    var followers: Int?
    var location: String?
}

final class Repo: Codable {
    var stargazers_count: Int?
}

final class User: GHUItem, Codable {
    var login: String?
    var id: Int?
    var avatar_url: String?
    var avatar_data: Data?
    var html_url: String?
    var info: UserInfo?
    var repos: [Repo]?
    var stars: Int? {
        get {
            var result = 0
            if let _repos = repos {
                for _repo in _repos {
                    result += _repo.stargazers_count ?? 0
                }
                return result
            } else {
                return nil
            }
        }
    }
    
    func downloadAvatar() {
        guard avatar_url != nil && avatar_data == nil else { return }
        
        URLSession.shared.dataTask(with: URL(string: avatar_url!)!) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil
                    else { return }
                self.avatar_data = data
                if let _login = self.login {
                    let dataDict:[String: String] = ["login": _login]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUserInfo"), object: nil, userInfo: dataDict)
                }
            }.resume()
    }
    
    func downloadUserInfo() {
        guard login != nil else { return }
        URLSession.shared.dataTask(with: URL(string: "https://api.github.com/users/\(login!)")!) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("application/json"),
                let data = data, error == nil
                else { return }

            let decoder = JSONDecoder()
            do {
                self.info = try decoder.decode(UserInfo.self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }

            if let _login = self.login {
                let dataDict:[String: String] = ["login": _login]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUserInfo"), object: nil, userInfo: dataDict)
            }
            }.resume()
    }

    func downloadUserStarred() {
        guard login != nil else { return }
        let URLString = "https://api.github.com/users/\(login!)/starred"
        URLSession.shared.dataTask(with: URL(string: URLString)!) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("application/json"),
                let data = data, error == nil
                else { return }
            
            let decoder = JSONDecoder()
            do {
                self.repos = try decoder.decode([Repo].self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }
            
            if let _login = self.login {
                let dataDict:[String: String] = ["login": _login]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUserInfo"), object: nil, userInfo: dataDict)
            }
            }.resume()
    }
}

