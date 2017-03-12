//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 8/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {

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
        defaultTextFieldConfiguration(for: topTextField)
        defaultTextFieldConfiguration(for: bottomTextField)
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
}

private extension MemeEditorViewController {
    func defaultTextFieldConfiguration(for textField: UITextField) {
        // Default memeTextAttributes
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
}

// MARK: IBActions
private extension MemeEditorViewController {
    @IBAction func cancelMemeEdition() {
        self.dismiss(animated: true)
    }

    @IBAction func selectImageFromCamera() {
        presentUIImagePicker(usingSourceType: .camera)
    }

    @IBAction func selectImageFromAlbum() {
        presentUIImagePicker(usingSourceType: .savedPhotosAlbum)
    }

    @IBAction func shareMeme() {
        if let generatedMeme = generateMemedImage() {
            let itemsToShare = [generatedMeme]
            let activityViewController = UIActivityViewController(activityItems: itemsToShare,
                                                                  applicationActivities: nil)
            // [weak self] is needed to avoid a strong reference cycle
            activityViewController.completionWithItemsHandler = { [weak self] activity, success, items, error in
                if success {
                    self?.save(generatedMeme)
                    self?.dismiss(animated: true)
                }
            }
            self.present(activityViewController, animated: true)
        }
    }
}

// MARK: UIImagePicker and UINavigation's delegate
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Preseting a UIImagePickerController with a specific sourceType
    func presentUIImagePicker(usingSourceType sourceType: UIImagePickerControllerSourceType) {
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
}

// MARK: UITextField's delegate
extension MemeEditorViewController: UITextFieldDelegate {
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
}

// MARK: Keyboard and view management
extension MemeEditorViewController {
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
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide, object: nil)
    }

    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

}

// MARK: Generate and save a Meme
private extension MemeEditorViewController {
    func save(_ generatedMemedImage: UIImage) {
        if let topText = topTextField.text, let bottomText = bottomTextField.text,
            let originalImage = selectedImage.image {

            if let originalImageName = saveImageToFile(originalImage),
                let memedImageName = saveImageToFile(generatedMemedImage) {
                // Creating a new meme to be stored
                let meme = Meme(topText: topText, bottomText: bottomText,
                                originalImageName: originalImageName, memedImageName: memedImageName)
                // Persisting data
                meme.save()
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    // Appeding the meme in the AppDelegate's memes property
                    appDelegate.memes.append(meme)
                }
            }
        }
    }

    func saveImageToFile(_ image: UIImage) -> String? {
        // creating a unique name to the new image
        let newImageName = UUID().uuidString + ".jpg"
        if let data = UIImageJPEGRepresentation(image, 0.3) {
            let filename = FileUtils.documentDirectory.appendingPathComponent(newImageName)
            do {
                try data.write(to: filename)
                return newImageName
            } catch {
                print("Error while saving file: \(error.localizedDescription)")
            }
        }
        return nil
    }

    func generateMemedImage() -> UIImage? {
        // Creating image context using the actual view size
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
        // Trying to take a snapshot of the view hierarchy into the current context
        if view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true) {
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                // Rectangle containing the image with the top and bottom text
                let rect = selectedImage.frame
                let scale = image.scale
                let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale,
                                        width: rect.size.width * scale, height: rect.size.height * scale)
                // cropping the image to only use the UIViewImage's image, not the entire screen
                if let croppedImage = image.cgImage?.cropping(to: scaledRect) {
                    return UIImage(cgImage: croppedImage, scale: scale, orientation: .up)
                }
            }
        }
        return nil
    }

    func setToolBarsIsHidden(to isHidden: Bool) {
        topToolBar.isHidden = isHidden
        bottomToolBar.isHidden = isHidden
    }
}
