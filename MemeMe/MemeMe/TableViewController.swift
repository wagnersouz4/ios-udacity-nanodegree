//
//  TableViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 11/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    private var memes = [Meme]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Loading the memes
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            memes = appDelegate.memes
        }
    }
}
