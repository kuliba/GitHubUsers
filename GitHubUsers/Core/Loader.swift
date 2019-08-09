//
//  Loader.swift
//  GitHubUsers
//
//  Created by Valentin Ozerov on 07/08/2019.
//  Copyright © 2019 Valentin Ozerov. All rights reserved.
//

import UIKit

class Loader: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // your destination file url
        let fileName = "\(downloadTask.hashValue)"
        let destination = documentsUrl.appendingPathComponent(fileName)

        guard
            let httpURLResponse = downloadTask.response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = downloadTask.response?.mimeType, mimeType.hasPrefix("application/json")
            else {
                // GitHub отдал невалидный JSON. Вероятная ошибка - превышение числа запросов в час
                print(downloadTask.response!)
                return
        }
        do {
            // remove previously file
            if FileManager().fileExists(atPath: destination.path) {
                try FileManager().removeItem(atPath: destination.path)
            }
            try FileManager().moveItem(at: location, to: destination)
            
            delegate?.downloadTask(hashValue: downloadTask.hashValue)
        } catch {
            print(error)
        }

    }
    
    // Can't init is singleton
    override private init() {
        super.init()
    }
    // MARK: Shared Instance
    static let shared = Loader()
    weak var delegate: LoadManager?
    
    public func download(URLString: String) -> URLSessionDownloadTask {
        let requestURL: URL = URL(string: URLString)!
        let urlRequest: URLRequest = URLRequest(url: requestURL as URL)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        
        let downloads = session.downloadTask(with: urlRequest)
        
        downloads.resume()
        return downloads
    }
}
