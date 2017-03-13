//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 11/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet private weak var memeDetailImage: UIImageView!
    var meme: Meme!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                 target: self, action: #selector(editMeme))
    }

    override func viewWillAppear(_ animated: Bool) {
        if let meme = meme {
            memeDetailImage.image = meme.memedImageAsUIImage
        }
    }
}

private extension MemeDetailViewController {
   @objc func editMeme() {
        if let memeEditorVC = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController")
            as? MemeEditorViewController {
            memeEditorVC.meme = meme
            present(memeEditorVC, animated: true)
        }
    }
}
