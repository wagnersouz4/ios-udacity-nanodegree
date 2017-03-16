//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 11/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var memeDetailImage: UIImageView!
    var viewingMemeIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

private extension MemeDetailViewController {
    func addRightBarButtons() {
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMeme))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        navigationItem.rightBarButtonItems = [UIBarButtonItem]()
        navigationItem.rightBarButtonItems?.append(shareButton)
        navigationItem.rightBarButtonItems?.append(editButton)
    }

    func loadData() {
        if let index = viewingMemeIndex,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let meme = appDelegate.memes[index]
            memeDetailImage.image = UIImage(contentsOfFile: meme.memedImageURL.path)
        }
    }
}

// MARK: UIBarButtons' actions
private extension MemeDetailViewController {
    @objc func editMeme() {
        if let memeEditorVC = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController")
            as? MemeEditorViewController {
            memeEditorVC.editingMemeIndex = viewingMemeIndex
            present(memeEditorVC, animated: true)
        }
    }

    @objc func share() {
        if let image = memeDetailImage.image {
            let itemsToShare = [image]
            let activityViewController = UIActivityViewController(activityItems: itemsToShare,
                                                                  applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { [weak self] activity, success, items, error in
                if success {
                    self?.dismiss(animated: true)
                }
            }
            self.present(activityViewController, animated: true)
        }
    }
}
