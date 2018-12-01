//
//  ListViewController.swift
//  CheckTheList
//
//  Created by Melanie MacDonald on 2018-11-08.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseUI
import GoogleSignIn
import CoreData
import Firebase
import FirebaseAuth

class ListViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UINavigationControllerDelegate, UIPickerViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descrTextView: UITextView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var optParticipant1: UILabel!
    @IBOutlet weak var optParticipant2: UILabel!//hidden by default
    @IBOutlet weak var optParticipant3: UILabel!//hidden by default
    @IBOutlet weak var participantPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //Sample options for the pickers for testing purposes
    let participantOptions = ["username1", "username2", "username3"]
    

    // Controls whether passing in a new or preexisting list
    var checklist: List?
    
    var isEdit: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        descrTextView.delegate = self
        participantPicker.delegate = self
        participantPicker.dataSource = self
        
        //Create a black border around the description text view
        descrTextView.layer.borderWidth = 1
        descrTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        
        if let checklist = checklist {
            isEdit = true
            navigationItem.title = checklist.name
            nameTextField.text = checklist.name
            descrTextView.text = checklist.descr
            dueDatePicker.setDate(checklist.dueDate, animated: true)
            // TODO insert code for participants
        } else {
            isEdit = false
        }
        
        
        
        var  User = Auth.auth().currentUser!
        Print(User.displayName)
        
        
        //TODO: Handling for save button depending on if appropriate fields have been filled in
    }
    
    //MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //executes after done editing, can disable save button or not (TODO)
        navigationItem.title = textField.text
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Executes on user tapping text field to edit
        saveButton.isEnabled = false
    }
    
    //MARK: UITextViewDelegate
    
    //Setup for handling to resign the texr view keyboard
    func textViewDidBeginEditing(_ textView: UITextView) {
        cancelButton.title = "Done"
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        cancelButton.title = "Cancel"
    }
    
    //MARK: UIPickerDataSource
    
    func numberOfComponents(in dateDuePicker: UIPickerView) -> Int {
        return 1
    }
    
    // Sets the number of options for the pickers as according to their tag values, and the number of elements in
    // their "options" arrays
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1) {
            return participantOptions.count
        }
        else {
            return participantOptions.count
        }
    }
    
    // Sets the values of the pickers as according to their tag values
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // The due date picker has a tag of 1
        if (pickerView.tag == 1){
            return "\(participantOptions[row])"
        }
            // The priority picker has a tag of 2
        else{
            return "\(participantOptions[row])"
        }
    }
    
    // Shows the participant picker if number of participants does not exceed three, TODO
    /*func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1 && row == 1){
            doHideDatePicker(flag: false)
        }
        else if (pickerView.tag == 1){
            doHideDatePicker(flag: true)
        }
    }*/
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: Any) {
        // This button should dismiss the text view keyboard if it is open
        if cancelButton.title == "Done" {
            descrTextView.resignFirstResponder()
        }
        
        //Depending on style of presentation (modal or push), this view should be dismissed differently (is treated differently whether it was used to "Add" or "Edit")
        let isPresentingInAddMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMode && !isEdit!{
            dismiss(animated: true, completion: nil)
        }
        /*else if isPresentingInAddMode && isEdit == true {
            navigationController!.popViewController(animated: true)
        }*/
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The List View Controller is not inside a navigation controller")
        }
    }
    
    // Configure a view controller before it's presented
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     super.prepare(for: segue, sender: sender)
     
     // Confgure the destination view controller only when save button is pressed
     guard let button = sender as? UIBarButtonItem, button === saveButton else {
     os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
     return
     }
     
     let name = nameTextField.text ?? ""
     let descr = descrTextView.text ?? ""
     let dueDate = dueDatePicker.date
     let participants = [String]() // placeholder, TODO
     let isPresentingInAddItemMode = presentingViewController is UINavigationController
     
     if isPresentingInAddItemMode {//??
     }
     
     // Set the list to be passed to ListTableViewController after the unwind seque
     
        checklist = List(name: name, descr: descr, dueDate: dueDate, participants: participants)
     }
    
    //MARK: Custom Functions
    
    //TODO implement save button enabled toggle here
    
    //TODO write function to toggle visibility of participants and picker conditionally
}

