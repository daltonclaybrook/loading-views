//
//  ViewController.swift
//  LoadingViews
//
//  Created by Dalton Claybrook on 2/12/17.
//  Copyright © 2017 Claybrook Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var segmentView: CircleSegmentView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentView.startAnimating()
    }
}

