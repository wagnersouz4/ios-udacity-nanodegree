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
        cell.memeImage.image = memes[indexPath.row].memedImage
        return cell
    }
}

// MARK: Collection view and delegate
extension MemesCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let memeDetailVC = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController")
            as? MemeDetailViewController {
            memeDetailVC.memeDetailImage.image = memes[indexPath.row].memedImage
            self.navigationController?.pushViewController(memeDetailVC, animated: true)
        }
    }
}
