//
//  ViewController.swift
//  MemeMeOne
//
//  Created by Peter Mäder on 17.02.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import UIKit

struct Meme {
    var topText : String
    var bottomText: String
    
    let originalImage : UIImage
    var memeImage: UIImage
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //TOP Toolbar Outlets
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var topToolBarAction: UIBarButtonItem!
    @IBOutlet weak var topToolBarCancel: UIBarButtonItem!

    //Bottom Toolbar Outlets
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    //IMAGE View Outlet
    @IBOutlet weak var imageView: UIImageView!
    
    //TEXT Field Outlets
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    //BOTTOM Toolbar Outlets
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //DELEGATES
    let memeMeTFDelegate = MemeMeTextFieldDelegate()

    //TEXT Field Attribute Settings
    let memeTextAttributes = [
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSStrokeWidthAttributeName : NSNumber.init(float: -2.0)
    ]
    
    //View Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = memeMeTFDelegate
        bottomTextField.delegate = memeMeTFDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        //Enable camera button only if the device has a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        subscribeToKeyboardNotifications()
        
        //configure topTextField
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        topTextField.adjustsFontSizeToFitWidth = true
        topTextField.textAlignment = NSTextAlignment.Center
        
        //configure bottomTextField
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        bottomTextField.adjustsFontSizeToFitWidth = true
        bottomTextField.textAlignment = NSTextAlignment.Center
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //Cancel Button related Source code
    @IBAction func topBarCancelPressed(sender: AnyObject) {
        //reset Text Fields and top Bar
        topTextField.hidden = true
        topTextField.text = "TOP"
        
        bottomTextField.hidden = true
        bottomTextField.text = "BOTTOM"
        topToolBar.hidden = true
        
        imageView.image = nil

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Image Picker related source code
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }

    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
            topTextField.hidden = false
            bottomTextField.hidden = false
            topToolBar.hidden = false
        } else{
            topTextField.hidden = true
            bottomTextField.hidden = true
            topToolBar.hidden = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //TOP Toolbar Actions
    @IBAction func shareActivityView(sender: AnyObject) {
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image! , memeImage: generateMemedImage())
        let shareItems = [meme.memeImage]
        
        let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil )
        
        presentViewController(activityController, animated: true, completion: { UIImageWriteToSavedPhotosAlbum(meme.memeImage, nil, nil, nil) } )
    }
    
    func generateMemedImage() -> UIImage
    {
        //hide unnecessary toolbars
        self.topToolBar.hidden = true
        self.bottomToolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        imageView.drawViewHierarchyInRect(self.imageView.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //unhide unnecessary toolbars
        self.topToolBar.hidden = false
        self.bottomToolBar.hidden = false
        
        return memedImage
    }
    
    //Move keyboard to see edited Text in BottomTextfield
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        //Keyboard must shift view ONLY if bottom Text field is editing
        if bottomTextField.editing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(notification: NSNotification){
        //Keyboard must shift view back ONLY if bottom Text field is editing
        if bottomTextField.editing {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}

