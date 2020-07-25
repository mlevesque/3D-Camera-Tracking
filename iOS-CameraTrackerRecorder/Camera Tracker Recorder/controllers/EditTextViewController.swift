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
    
    override func viewDidLoad() {
        projectText.delegate = self
        sceneText.delegate = self
        takeText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nameData = PersistentData.shared.getNameData()
        projectText.text = nameData.projectName
        sceneText.text = nameData.scene
        takeText.text = "\(nameData.take)"
    }
    
    /// Returns a name data object from the text field values
    /// - Returns:
    func getNameData() -> NameData {
        return NameData(
            projectName: projectText.text ?? "",
            scene: sceneText.text ?? "",
            take: Int(takeText.text ?? "1") ?? 1)
    }
    
    func dismissKeypad() {
        takeText.resignFirstResponder()
    }
}

// MARK: UI TextField Methods

extension EditTextViewController : UITextFieldDelegate {
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
            return Validations.isTakeValid(fullString)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// MARK: UI Actions

extension EditTextViewController {
    @IBAction func onEditTextBegin(_ sender: Any) {
        if let textField = sender as? UITextField {
            textField.selectAll(nil)
        }
    }
    
    @IBAction func onProjectEditEnd(_ sender: Any) {
        fallbackIfEmpty(textField: sender as? UITextField, fallbackValue: "ProjectName")
    }
    
    @IBAction func onSceneEditEnd(_ sender: Any) {
        fallbackIfEmpty(textField: sender as? UITextField, fallbackValue: "1")
    }
    
    @IBAction func onTakeEditEnd(_ sender: Any) {
        fallbackIfEmpty(textField: sender as? UITextField, fallbackValue: "1")
    }
    
    private func fallbackIfEmpty(textField: UITextField?, fallbackValue: String) {
        if takeText?.text?.isEmpty ?? true {
            textField?.text = fallbackValue
        }
    }
    
    @IBAction func onTakeResetTouchUp(_ sender: Any) {
        takeText.text = "1"
    }
}
