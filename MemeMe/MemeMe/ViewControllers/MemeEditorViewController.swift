//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Wagner Souza on 8/03/17.
//  Copyright © 2017 Wagner Souza. All rights reserved.
//

import UIKit

// MARK: Extension to UITextField to load MemeEditor's default style
private extension UITextField {
    func loadMemeStyleDefaults() {
        // Default memeTextAttributes
        let memeTextAttributes: [String: Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -1
        ]
        self.defaultTextAttributes = memeTextAttributes
        self.textAlignment = .center
    }
}

class MemeEditorViewController: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var selectFromCameraButton: UIBarButtonItem!
    @IBOutlet weak var selectFromAlbumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!

    var editingMemeIndex: Int?
    // This property is needed when the user is edting a Meme and wants to change its background.
    // The reason is that when the Imagepicker dismiss the view will appear again but there the image
    // should not be updated with the old Meme image, but keep using the selected one.
    var editingMemeBackgroundHasChanged = false
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.loadMemeStyleDefaults()
        topTextField.delegate = self
        bottomTextField.loadMemeStyleDefaults()
        bottomTextField.delegate = self
        topToolBar.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureEditor()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
}

private extension MemeEditorViewController {
    func configureEditor() {
        // Enable the select from camera feature only if there is a camera available.
        selectFromCameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        // If the meme is being edited
        if let index = editingMemeIndex,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let meme = appDelegate.memes[index]
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            if !editingMemeBackgroundHasChanged {
                self.selectedImage.image = UIImage(contentsOfFile: meme.originalImagePath)
            }
        } else {
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
        }
        let memeHasImage = selectedImage.image != nil
        shareButton.isEnabled = memeHasImage
        saveButton.isEnabled = memeHasImage
        subscribeToKeyboardNotifications()
    }

    // Preseting a UIImagePickerController with a specific sourceType
    func presentUIImagePicker(usingSourceType sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true)
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

    @IBAction func saveMeme() {
        if let generatedMeme = generateMemedImage() {
            self.save(generatedMeme)
        }
        self.dismiss(animated: true)
    }
}

// MARK: UIImagePicker and UINavigation's delegate
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Delegate method to set the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.selectedImage.image = image
            editingMemeBackgroundHasChanged = true
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
                let newMeme = Meme(topText: topText, bottomText: bottomText,
                                   originalImageName: originalImageName, memedImageName: memedImageName)

                //If the meme is being edited
                if let index = editingMemeIndex,
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    let memeToUpdate = appDelegate.memes[index]
                    memeToUpdate.update(using: newMeme)
                } else {
                    // Persisting data
                    newMeme.save()
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        // Appeding the meme in the AppDelegate's memes property
                        appDelegate.memes.append(newMeme)
                    }
                }
            }
        }
    }

    func saveImageToFile(_ image: UIImage) -> String? {
        // creating a unique name to the new image
        let newImageName = UUID().uuidString + ".jpg"
        if let data = UIImageJPEGRepresentation(image, 0.8) {
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
}
