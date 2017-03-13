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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                 target: self, action: #selector(editMeme))
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
   @objc func editMeme() {
        if let memeEditorVC = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController")
            as? MemeEditorViewController {
            memeEditorVC.editingMemeIndex = viewingMemeIndex
            present(memeEditorVC, animated: true)
        }
    }

    func loadData() {
        if let index = viewingMemeIndex,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let meme = appDelegate.memes[index]
            memeDetailImage.image = meme.memedImageAsUIImage
        }
    }
}
