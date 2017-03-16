//
//  MemesTableViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 11/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

extension UIImageView {

    func roundBorders(using color: CGColor? = nil) {
        self.layer.borderColor = color ?? UIColor.white.cgColor
        self.layer.borderWidth = CGFloat(4)
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }

}

class MemesTableViewController: UITableViewController {
    var memes = [Meme]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMemes()
    }
}

private extension MemesTableViewController {
    func loadMemes() {
        // Loading the memes
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            memes = appDelegate.memes
        }
        tableView.reloadData()
    }
}

// MARK: Table view and data source
extension MemesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell", for: indexPath)
            as? MemeTableViewCell else { fatalError("Dequeuing has failed!") }
        let meme = memes[indexPath.row]
        cell.bottomLabel.text = meme.bottomText
        cell.topLabel.text = meme.topText
        cell.loadingIndicator.alpha = 1.0
        cell.loadingIndicator.startAnimating()
        FileUtils.readAsync(contentsOfFile: meme.originalImageURL, completionHandler: { data in
            if let data = data {
                cell.customImageView.image = UIImage(data: data)
                cell.customImageView.alpha = 0
                UIView.animate(withDuration: 0.3, animations: {
                    cell.customImageView.alpha = 1
                    cell.loadingIndicator.alpha = 0
                }, completion: {_ in
                    cell.loadingIndicator.stopAnimating()
                })
            }
        })
        cell.customImageView.roundBorders()
        return cell
    }
}

// MARK: Table view and delegate
extension MemesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let memeDetailVC = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController")
            as? MemeDetailViewController {
            memeDetailVC.viewingMemeIndex = indexPath.row
            self.navigationController?.pushViewController(memeDetailVC, animated: true)
        }
    }
}

// MARK: @IBActions and segues' prepare
extension MemesTableViewController {
    @IBAction func createNewMeme() {
        self.performSegue(withIdentifier: "SegueTableViewEditor", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "SegueTableViewEditor" {
                if let destination = segue.destination as? MemeEditorViewController {
                    destination.editingMemeIndex = nil
                }
            }
        }
    }
}
