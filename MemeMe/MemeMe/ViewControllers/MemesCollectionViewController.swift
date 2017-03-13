//
//  MemesCollectionViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 11/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class MemesCollectionViewController: UICollectionViewController {
    var memes = [Meme]()
    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMemes()
    }
}

extension MemesCollectionViewController {
    func loadMemes() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            memes = appDelegate.memes
        }
        collectionView?.reloadData()
    }
}

// MARK: Collection view and data source
extension MemesCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionCell", for: indexPath)
            as? MemeCollectionViewCell else { fatalError("Dequeuing has failed!") }

        cell.memedImage.image = memes[indexPath.row].memedImageAsUIImage
        return cell
    }
}

// MARK: Collection view and delegate
extension MemesCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let memeDetailVC = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController")
            as? MemeDetailViewController {
            memeDetailVC.viewingMemeIndex = indexPath.row
            self.navigationController?.pushViewController(memeDetailVC, animated: true)
        }
    }
}

// MARK: @IBActions and segues' prepare
extension MemesCollectionViewController {
    @IBAction func createNewMeme() {
        performSegue(withIdentifier: "SegueCollectionViewEditor", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "SegueCollectionViewEditor" {
                if let destination = segue.destination as? MemeEditorViewController {
                    destination.editingMemeIndex = nil
                }
            }
        }
    }
}
