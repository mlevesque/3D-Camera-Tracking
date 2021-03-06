//
//  UITextFieldExtension.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 8/10/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import UIKit

/// This adds extra functionality to text fields, allowing for a done button to appear on the onscreen keyboard.
extension UITextField {
    /// Allows us to add a done button to the keyboard.
    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    /// Adds Done button to keyboard.
    func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    /// Triggered when the Done button is tapped. Will end editing on the textfield.
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}
