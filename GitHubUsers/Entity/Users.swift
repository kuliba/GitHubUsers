//
//  Users.swift
//  GitHubUsers
//
//  Created by Valentin Ozerov on 07/08/2019.
//  Copyright © 2019 Valentin Ozerov. All rights reserved.
//

import Foundation

final class Users: NSObject {
    // Can't init is singleton
    override private init() {
        super.init()
    }

    // MARK: Shared Instance
    static let shared = Users()

    var users = [User]()
    var downloadTasks = [(Int?, Int)]()
    
    subscript(index: Int) -> User {
        get {
            while index >= users.count {
                let lastId = getLastId()
                if users.isEmpty || lastId != nil {
                    downloadTasks.append((lastId, LoadManager.shared.downloadUsers(since: lastId)))
                }
                for _ in 0...29 {
                    users.append(User())
                }
            }
            return users[index]
        }
        set(newValue) {
            users[index] = newValue
        }
    }
    
    func getLastId() -> Int? {
        guard !users.isEmpty else { return nil }
        return users.last?.id
    }
    
    func initUsers(downloadTaskHashValue: Int) {
        var index = -1
        var downloadTask: (lastId: Int?, downloadTaskHashValue: Int) = (nil, 0)
        
        for (_index, _downloadTask) in downloadTasks.enumerated() {
            if _downloadTask.1 == downloadTaskHashValue {
                index = _index
                downloadTask = _downloadTask
            }
        }
        
        guard index >= 0 && downloadTask.downloadTaskHashValue > 0 else { return }
        
        let usersList = Storage.retrieve("\(downloadTask.downloadTaskHashValue)", as: [User].self)

        // Add download info to created but empty users
        for (_index, _user) in usersList.enumerated() {
            let user = users[_index + index * 30]
            user.login = _user.login
            user.id = _user.id
            user.avatar_url = _user.avatar_url
            user.html_url = _user.html_url
            user.downloadAvatar()
            user.downloadUserInfo()
            user.downloadUserStarred()
        }
        
        // get lastId and set to downloadTask
        downloadTask.lastId = usersList.last?.id

        // Run new list download if need
        if users.count > (index + 1) * 30 {
            downloadTasks.append((nil, LoadManager.shared.downloadUsers(since: downloadTask.lastId)))
        }
    }
    
    func isUserInit(user: User?) -> Bool {
        if let _user = user {
            return _user.id != nil
                && _user.login != nil
                && _user.avatar_url != nil
                && _user.avatar_data != nil
                && _user.info != nil
                && _user.repos != nil
        }
        return false
    }
}
