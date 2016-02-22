//
//  MemeMeTextFieldDelegate.swift
//  MemeMeOne
//
//  Created by Peter Mäder on 18.02.16.
//  Copyright © 2016 Peter Mäder. All rights reserved.
//

import Foundation
import UIKit

class MemeMeTextFieldDelegate : NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text! == "BOTTOM" || textField.text! == "TOP"){
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}