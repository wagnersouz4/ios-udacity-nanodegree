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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if let index = viewingMemeIndex {
            let meme = appDelegate.memes[index]
            memeDetailImage.image = UIImage(contentsOfFile: meme.memedImageURL.path)
        }
    }
}

// MARK: UIBarButtons' actions
private extension MemeDetailViewController {
    @objc func editMeme() {
        guard let memeEditorVC = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController")
            as? MemeEditorViewController else { return }
        memeEditorVC.editingMemeIndex = viewingMemeIndex
        present(memeEditorVC, animated: true)
    }

    @objc func share() {
        guard let image = memeDetailImage.image else { return }
        let itemsToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare,
                                                              applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [unowned self] _, success, _, _ in
            if success {
                self.dismiss(animated: true)
            }
        }
        self.present(activityViewController, animated: true)
    }
}
