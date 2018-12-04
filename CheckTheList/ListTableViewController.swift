//
//  ListTableViewController.swift
//  CheckTheList
//
//  Created by Melanie MacDonald on 2018-11-26.
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

class ListTableViewController: UITableViewController {

    //MARK: Properties
   let db = Firestore.firestore()
    var lists = [List]()
    var checklistName:String = ""
    var checklistDesc:String = ""
    var checklistDueDate:Timestamp = Timestamp.init()
   var checklist : [String] = []
    var date : Date = Date()
    var userP : [String] = []
    
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
      // lists.removeAll()
        
      //  let db2 = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.email!).collection("sharedChecklist")
        // Hook up edit button to use default API
        navigationItem.rightBarButtonItem = editButtonItem
       loadSampleItems()
        
        // TODO: display saved items from firebase
        
    }
    
   
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1// maybe 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "ListTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ListTableViewCell else {
            fatalError("The dequeued cell is not an instance of ListTableViewCell")
        }

        // Fetches the appropriate list
        let list = lists[indexPath.row]
       
        cell.listName.text = list.name
        cell.listDueDate.text = convertDateToString(date: list.dueDate)
        if list.participants.count == 0 {
            cell.participantFlag.isHidden = true
        }
        //TODO: Handling for completion

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //TODO: Check here if list is complete, prompt user if they are sure if it isn't
            // Delete the row from the data source
            let list = lists[indexPath.row]
           
            deleteChecklist(checklistId: list.listId)
            
            lists.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            //save items
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new checklist", log: OSLog.default, type: .debug)
        case "EditItem":
            guard let listItemDetailViewController = segue.destination as? ListViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let button = sender as? UIButton else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let selectedItemCell = button.superview?.superview as? ListTableViewCell else {
                fatalError("Could not get parent cell")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItem = lists[indexPath.row]
            listItemDetailViewController.checklist = selectedItem
        case "ShowDetail":
            guard let tasksViewController = segue.destination as? TaskTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? ListTableViewCell else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItem = lists[indexPath.row].listId
            tasksViewController.checklistID = selectedItem
        default:
            fatalError("Unexpected Segue Identifer; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
   @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
    if let sourceViewController = sender.source as? ListViewController{
        loadSampleItems()
        
    }/*, let
            list = sourceViewController.checklist {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing item
                lists[selectedIndexPath.row] = list
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new item
                let newIndexPath = IndexPath(row: lists.count, section: 0)
                lists.append(list)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the items
            //saveItems()*/
        }
    
    // TODO: Propagate this to Firebase when checked, should be marked completed
    func toggleCompletion(_ cell : ListTableViewCell) {
        cell.completedFlag.setImage(UIImage(named: "checked"), for: .normal)
        cell.isUserInteractionEnabled = false
        cell.textLabel!.isEnabled = false
        cell.alpha = 0.3
        
        
        
    }
    
    @IBAction func markCompleted(_ sender: AnyObject?) {
        let cell = (sender?.superview?.superview as? ListTableViewCell)!
        if cell.completedFlag.image(for: .normal) == UIImage(named: "checked") {
            return
        }
        let alert = UIAlertController(title: "Are you sure you want to continue?", message: "Marking the list completed will alert all participants and prevent any future changes.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in self.toggleCompletion(cell)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
    func sortCompletion() {
        let sortedList = lists.sorted {
            let number1 = $0.isCompleted ? 1 : 0
            let number2 = $1.isCompleted ? 1 : 0
            return number1 < number2
        }
        lists = sortedList
        self.tableView.reloadData()
        
    }
    
    func sortDueDate() {
        let sortedList = lists.sorted {
            return $0.dueDate < $1.dueDate
        }
        lists = sortedList
        self.tableView.reloadData()
    }
    
    func sortTitle() {
        let sortedList = lists.sorted {
            return $0.name < $1.name
        }
        lists = sortedList
        self.tableView.reloadData()
    }
    
    @IBAction func sortOptionsDisplay(_ sender: Any) {
        let alert = UIAlertController(title: "How would you like to sort?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sort by Completion", style: .default, handler: { action in self.sortCompletion()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Due Date", style: .default, handler: { action in self.sortDueDate()
        }))
        alert.addAction(UIAlertAction(title: "Sort by Title", style: .default, handler: { action in self.sortTitle()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    //MARK: Private Methods
    
    private func loadSampleItems() {
        
        
       
        //var check : [String] = []
        db.collection("Users").document(Auth.auth().currentUser!.email!).collection("sharedChecklist")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
               
                let values = documents.map{$0["checklistID"]!}
               
                for value in values {
                    let x = value as! String
                    
                    if !self.checklist.contains(x) {self.checklist.append(x)
                    }
                }
               print(self.checklist)
                for check in self.checklist{
                
                    self.db.collection("Cheklists").document(check)
                        .addSnapshotListener { documentSnapshot, error in
                            guard let document = documentSnapshot else {
                                print("Error fetching document: \(error!)")
                                return
                            }
                            guard let data = document.data() else {
                                print("Document data was empty.")
                                return
                            }
                            
                            self.checklistName = data["checklistName"] as! String
                            self.checklistDesc = data["description"] as! String
                            self.checklistDueDate = data["dueDate"] as! Timestamp
                            
                            let participants = data["participants"]
                            
                            if participants != nil {
                                self.userP = ["user1", "user2", "user3"]
                                
                            }
                            
                            self.date = self.checklistDueDate.dateValue()
                            
                            guard let list2 = List(name: self.checklistName, descr: self.checklistDesc, dueDate: self.date ,participants: self.userP, isCompleted: data["status"] as! Bool, listId : data["checklistId"] as! String) else {
                                fatalError("Unable to instantiate list item2")
                            }
                            
                            
                            // print(checklistName,checklistDesc, date, userP)
                            
                            
                            self.lists.append(list2)
                          
                            
                          
                            self.tableView.reloadData()
                            
                            
                    }
                    
                }
        }
   }
    // Converts a Date object into a readable String
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }

    func deleteChecklist(checklistId:String){
        
        db.collection("Users").document(Auth.auth().currentUser!.email!).collection("sharedChecklist").whereField("checklistID", isEqualTo: checklistId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.db.collection("Users").document(Auth.auth().currentUser!.email!).collection("sharedChecklist").document(document.documentID).delete(){ err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                    }
                }
        }
     
        db.collection("Cheklists").document(checklistId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
               self.lists.removeAll()
                self.loadSampleItems()
                self.tableView.reloadData()
                
            }
        }
     

 
        
    }

}
