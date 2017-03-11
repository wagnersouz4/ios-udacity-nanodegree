//
//  MemesTableViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 11/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class MemesTableViewController: UITableViewController {
    var memes = [Meme]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMemes()
    }
}

extension MemesTableViewController {
    func loadMemes() {
        // Loading the memes
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
           memes = appDelegate.memes
        }
    }
}

// MARK: Table view and data source
extension MemesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Set cell's attributes -> use a configure method in the cells as cast to have it
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell", for: indexPath)
        return cell
    }
}

// MARK: Table view and delegate
extension MemesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let memeDetailVC = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as? MemeDetailViewController {
            memeDetailVC.memeDetailImage.image = memes[indexPath.row].memedImage
            self.navigationController?.pushViewController(memeDetailVC, animated: true)
        }
    }
}
