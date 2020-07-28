//
//  EditTextViewController.swift
//  Camera Tracker Recorder
//
//  Created by Michael Levesque on 8/5/19.
//  Copyright © 2019 Michael Levesque. All rights reserved.
//

import UIKit

/// Controller for the edit project name popover view
class EditTextViewController: UIViewController {
    @IBOutlet var projectText: UITextField!
    @IBOutlet var sceneText: UITextField!
    @IBOutlet var takeText: UITextField!
    @IBOutlet var stepperTake: UIStepper!
    
    /// Sets up the delegates upon load.
    override func viewDidLoad() {
        projectText.delegate = self
        sceneText.delegate = self
        takeText.delegate = self
    }
    
    /// Sets up the UI.
    /// - Parameter animated:
    override func viewWillAppear(_ animated: Bool) {
        let nameData = PersistentData.shared.getNameData()
        projectText.text = nameData.projectName
        sceneText.text = nameData.scene
        takeText.text = "\(nameData.take)"
        stepperTake.value = Double(nameData.take)
    }
    
    /// Returns a name data object from the text field values
    /// - Returns:
    func getNameData() -> NameData {
        return NameData(
            projectName: projectText.text ?? "",
            scene: sceneText.text ?? "",
            take: Int(takeText.text ?? "1") ?? 1)
    }
    
    /// Dismisses the keyboard
    func dismissKeypad() {
        takeText.resignFirstResponder()
    }
}

// MARK: UI TextField Methods

extension EditTextViewController : UITextFieldDelegate {
    /// This will select all text when user begins editing a text field.
    /// - Parameter textField:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.selectAll(nil)
        }
    }
    
    /// Performs validation as text is entered into the text fields.
    /// - Parameters:
    ///   - textField: The textfield being edited
    ///   - range: range of text being replace/deleted
    ///   - string: text being added to the field
    /// - Returns: True if the changes are permitted. False if they should be discarded.
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // form the full string
        let str: String = textField.text ?? ""
        let p1 = str.index(str.startIndex, offsetBy: range.lowerBound)
        let p2 = str.index(str.startIndex, offsetBy: range.upperBound)
        let fullString = String(str[str.startIndex..<p1]) + string + String(str[p2..<str.endIndex])
        
        // perform validation
        if textField == projectText {
            return Validations.isProjectNameValid(fullString)
        }
        else if textField == sceneText {
            return Validations.isSceneValid(fullString)
        }
        else if textField == takeText {
            guard Validations.isTakeValid(fullString) else {
                return false
            }
            stepperTake.value = Double(Int(fullString) ?? Int(stepperTake.minimumValue))
        }
        return true
    }
    
    /// Ends editing and removes onscreen keyboard.
    /// - Parameter textField: The textfield that was being edited
    /// - Returns: Will return false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// MARK: UI Actions

extension EditTextViewController {
    /// Triggered when ProjectName or Scene editing has ended.
    /// - Parameter sender: projectText or sceneText
    @IBAction func onTextFieldEditEnd(_ sender: Any) {
        fallbackIfEmpty(
            textField: sender as? UITextField,
            fallbackValue: PersistentData.shared.getString(forKey: .projectName))
    }
    
    /// Triggered when Take editing has ended
    /// - Parameter sender: takeText
    @IBAction func onTakeEditEnd(_ sender: Any) {
        fallbackIfEmpty(
            textField: sender as? UITextField,
            fallbackValue: PersistentData.shared.getInt(forKey: .take))
    }
    
    /// Checks if the given text field is empty and if so, will set the text to the fallback value.
    /// - Parameters:
    ///   - textField: textfield to affect
    ///   - fallbackValue: value to set the textfield to if the textfield is empty
    private func fallbackIfEmpty(textField: UITextField?, fallbackValue: String) {
        if takeText?.text?.isEmpty ?? true {
            textField?.text = fallbackValue
        }
    }
    
    /// Checks if the given text field is empty and if so, will set the text to the fallback value. This version is
    /// for the take text field and will update the stepper as well if needed.
    /// - Parameters:
    ///   - textField: textfield to affect
    ///   - fallbackValue: value to set the textfield to if the textfield is empty
    private func fallbackIfEmpty(textField: UITextField?, fallbackValue: Int) {
        if takeText?.text?.isEmpty ?? true {
            textField?.text = "\(fallbackValue)"
            if textField == takeText {
                stepperTake.value = Double(fallbackValue)
            }
        }
    }
    
    /// Triggered when the Take Reset button is tapped. Resets the take text and stepper.
    /// - Parameter sender:
    @IBAction func onTakeResetTouchUp(_ sender: Any) {
        stepperTake.value = stepperTake.minimumValue
        takeText.text = "\(Int(stepperTake.minimumValue))"
    }
    
    /// Triggered when the stepper value changes. Updates the take text.
    /// - Parameter sender:
    @IBAction func onStepperValueChanged(_ sender: Any) {
        if let stepper = sender as? UIStepper {
            takeText.text = "\(Int(stepper.value))"
        }
    }
}
