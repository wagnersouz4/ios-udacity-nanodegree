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

    func loadMemes() {
        // Loading the memes
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        memes = appDelegate.memes
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
            guard let data = data else { return }
            cell.customImageView.image = UIImage(data: data)
            cell.customImageView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                cell.customImageView.alpha = 1
                cell.loadingIndicator.alpha = 0
            }, completion: { _ in
                cell.loadingIndicator.stopAnimating()
            })
        })
        cell.customImageView.roundBorders()
        return cell
    }
}

// MARK: Table view and delegate
extension MemesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let memeDetailVC = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController")
            as? MemeDetailViewController else { return }
        memeDetailVC.viewingMemeIndex = indexPath.row
        self.navigationController?.pushViewController(memeDetailVC, animated: true)
    }
}

// MARK: @IBActions
extension MemesTableViewController {
    @IBAction func createNewMeme() {
        self.performSegue(withIdentifier: "SegueTableViewEditor", sender: nil)
    }
}

// MARK: Segues
extension MemesTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "SegueTableViewEditor", let destination = segue.destination as? MemeEditorViewController {
            destination.editingMemeIndex = nil
        }
    }
}
