//
//  LoadManager.swift
//  GitHubUsers
//
//  Created by Valentin Ozerov on 07/08/2019.
//  Copyright © 2019 Valentin Ozerov. All rights reserved.
//

import UIKit

fileprivate let baseURL = "https://api.github.com/users"

class LoadManager {
    // Create singleton
    private init() {
        Loader.shared.delegate = self
    }
    static let shared = LoadManager()
    
    func downloadUsers(since: Int?) -> Int {
        var stringURL = baseURL
        if let _since = since {
            stringURL += "?since=\(_since)"
        }
        return Loader.shared.download(URLString: stringURL).hashValue
    }
    
    func downloadTask(hashValue: Int) {
        Users.shared.initUsers(downloadTaskHashValue: hashValue)
        NotificationCenter.default.post(name: Notification.Name("userListDownloaded"), object: nil)
    }
}
