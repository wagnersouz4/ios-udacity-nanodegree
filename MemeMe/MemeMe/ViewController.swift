//
//  ViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 8/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // UIImageView containing the selected image
    @IBOutlet weak var selectedImage: UIImageView!

    @IBOutlet weak var selectFromCameraButton: UIBarButtonItem!
    @IBOutlet weak var selectFromAlbumButton: UIBarButtonItem!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Enable the select from camera feature only if there is a camera available.
        selectFromCameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    @IBAction func selectImageFromCamera() {
        presentUIImagePickerWithSourceType(.camera)
    }

    @IBAction func selectImageFromAlbum() {
        presentUIImagePickerWithSourceType(.savedPhotosAlbum)
    }

    // Preseting a UIImagePickerController with a specific sourceType
    private func presentUIImagePickerWithSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
}
