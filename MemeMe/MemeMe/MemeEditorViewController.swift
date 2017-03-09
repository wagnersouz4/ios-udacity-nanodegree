//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 8/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate,
                    UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var selectFromCameraButton: UIBarButtonItem!
    @IBOutlet weak var selectFromAlbumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialTextFieldConfiguration(for: topTextField)
        initialTextFieldConfiguration(for: bottomTextField)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Enable the select from camera feature only if there is a camera available.
        selectFromCameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.isEnabled = selectedImage.image != nil
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }

    @IBAction func selectImageFromCamera() {
        presentUIImagePickerWithSourceType(.camera)
    }

    @IBAction func selectImageFromAlbum() {
        presentUIImagePickerWithSourceType(.savedPhotosAlbum)
    }

    private func initialTextFieldConfiguration(for textField: UITextField) {
        let memeTextAttributes: [String: Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -1
        ]

        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = .center
    }

    // Preseting a UIImagePickerController with a specific sourceType
    func presentUIImagePickerWithSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    // Delegate method to set the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage.image = image
        }
        dismiss(animated: true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dimissing the keyboard
        textField.resignFirstResponder()
        return true
    }

    // Moving the view when the keyboards covers the text field
    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            if let keyboardHeight = getKeyboardHeight(notification) {
                view.frame.origin.y = 0 - keyboardHeight
            }
        }
    }

    // Restoring the frame y position when the keyboard will hide
    func keyboardWillHide() {
            view.frame.origin.y = 0
    }

    // Using the userInfo notification's property to obtain the keyboard height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat? {
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
                return keyboardSize.height
            }
        }
        return nil
    }

    // Subscribing to the keyboard's willShow and willHide notification
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide, object: nil)
    }

    private func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    private func save() {
        if let topText = topTextField.text, let bottomText = bottomTextField.text,
            let originalImage = selectedImage.image, let memedImage = generateMemedImage() {
            let _ = Meme(topText: topText, bottomText: bottomText,
                         oiriginalImage: originalImage, memedImage: memedImage)
        }
    }

    private func generateMemedImage() -> UIImage? {
        // Rendering a View to an image
        UIGraphicsBeginImageContext(self.view.frame.size)

        // Before take the snapshot both top and bottom toolbar should be hidden
        setToolBarsIsHidden(to: true)
        view.snapshotView(afterScreenUpdates: true)
        setToolBarsIsHidden(to: false)
        if let memedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return memedImage
        }
        return nil
    }

    private func setToolBarsIsHidden(to isHidden: Bool) {
        topToolBar.isHidden = isHidden
        bottomToolBar.isHidden = isHidden
    }
}
