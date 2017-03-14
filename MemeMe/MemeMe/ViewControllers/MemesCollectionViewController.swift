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

    // Properties to be used in the flow layout
    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)

    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
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

// MARK: Collection view's flowlayout's delegate
extension MemesCollectionViewController: UICollectionViewDelegateFlowLayout {
    // Telling the size of a given cell to the layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculating the width of each item
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    // Space between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    // Space between each line
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
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
