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
    var memedImage: UIImage!

    override func viewWillAppear(_ animated: Bool) {
        if let memedImage = memedImage {
            memeDetailImage.image = memedImage
        }
    }
}
