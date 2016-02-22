//
//  ViewController.swift
//  MemeMeOne
//
//  Created by Peter Mäder on 17.02.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    let memeMeTFDelegate = MemeMeTextFieldDelegate()
    let memeTextAttributes = [
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSForegroundColorAttributeName : UIColor.whiteColor(),
//        NSStrokeColorAttributeName : UIColor.whiteColor(),
        NSStrokeWidthAttributeName : NSNumber.init(float: -2.0)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = memeMeTFDelegate
        bottomTextField.delegate = memeMeTFDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        subscribeToKeyboardNotifications()
        
        //configure topTextField
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        
        //configure bottomTextField
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = NSTextAlignment.Center
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
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
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //move keyboard to see edited Text in Textfield
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

