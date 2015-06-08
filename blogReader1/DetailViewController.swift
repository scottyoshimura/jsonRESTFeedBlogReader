//
//  DetailViewController.swift
//  blogReader1
//
//  Created by Scott Yoshimura on 5/29/15.
//  Copyright (c) 2015 west coast dev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem{
            if let wv = self.webView {
                //we have created a variable called detail from detail item that we weant to check that exists, it shoud exist becasue we created and set a value in the prepare for segue method.
                    //here we have a webview to update that we called wv. we check to see if it exists case hte code is run just before the webview is actually created.
                wv.loadHTMLString(detail.valueForKey("content")?.description, baseURL: nil)
                    // we want to load the html content
                //this will take the value for the key content which in this case is the html contnt and load it into the webview
            }
        }
        
          }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

