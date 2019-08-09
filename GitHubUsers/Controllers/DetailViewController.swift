//
//  ProfileViewController.swift
//  GitHubUsers
//
//  Created by Valentin Ozerov on 08/08/2019.
//  Copyright © 2019 Valentin Ozerov. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {


    @IBOutlet weak var webView: WKWebView!
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
 
    var html_url: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let address = html_url,
            let webURL = URL(string: address) {
            let urlRequest = URLRequest(url: webURL)
            webView.load(urlRequest)
        }
    }
}
