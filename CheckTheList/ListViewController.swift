//
//  ListViewController.swift
//  CheckTheList
//
//  Created by Melanie MacDonald on 2018-11-08.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit
import os.log

class ListViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UINavigationControllerDelegate, UIPickerViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descrTextView: UITextView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var optParticipant1: UILabel!
    @IBOutlet weak var participantPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addParticipant: UIButton!
    @IBOutlet weak var selectParticipant: UIButton!
    
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
            if checklist.participants.count != 0 {
                optParticipant1.text = checklist.participants.compactMap({$0}).joined(separator: ", ")
            }
            if optParticipant1.text?.components(separatedBy: ", ").count == 3 {
                addParticipant.isHidden = true
            }
        } else {
            saveButton.isEnabled = false
            isEdit = false
        }
        
    }
    
    //MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //executes after done editing, can disable save button or not (TODO)
        if textField.text != "" {
            saveButton.isEnabled = true
        }
        else {
            saveButton.isEnabled = false
        }
        navigationItem.title = textField.text
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Executes on user tapping text field to edit
        saveButton.isEnabled = false
    }
    
    //MARK: UITextViewDelegate
    
    //Setup for handling to resign the text view keyboard
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
            return participantOptions.count
    }
    
    // Sets the values of the pickers as according to their tag values
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return "\(participantOptions[row])"
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: Any) {
        // This button should dismiss the text view keyboard if it is open
        if cancelButton.title == "Done" {
            descrTextView.resignFirstResponder()
            return
        }
        
        //Depending on style of presentation (modal or push), this view should be dismissed differently (is treated differently whether it was used to "Add" or "Edit")
        let isPresentingInAddMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMode && !isEdit!{
            dismiss(animated: true, completion: nil)
        }
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
     var participants = optParticipant1.text?.components(separatedBy: ", ")
    if optParticipant1.text == "None" {
        participants = []
    }
    let isPresentingInAddItemMode = presentingViewController is UINavigationController
     
     if isPresentingInAddItemMode {//??
     }
     
     // Set the list to be passed to ListTableViewController after the unwind seque
     
        checklist = List(name: name, descr: descr, dueDate: dueDate, participants: participants!)
     }
    
    //MARK: Custom Functions
    
    @IBAction func addParticipant(_ sender: Any) {
        participantPicker.isHidden = false
        selectParticipant.isHidden = false
        addParticipant.isHidden = true
    }
    @IBAction func commitParticipant(_ sender: Any) {
        selectParticipant.isHidden = true
        participantPicker.isHidden = true
        addParticipant.isHidden = false
        if optParticipant1.text == "None" {
            optParticipant1.text = participantOptions[participantPicker.selectedRow(inComponent: 0)]
        }
        else {
            var participants = optParticipant1.text?.components(separatedBy: ", ")
        participants!.append(participantOptions[participantPicker.selectedRow(inComponent: 0)])
            optParticipant1.text = participants.flatMap({$0})!.joined(separator: ", ")
        }
        
        if optParticipant1.text?.components(separatedBy: ", ").count == 3 {
            addParticipant.isHidden = true
        }
    }
}

