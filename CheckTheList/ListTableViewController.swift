//
//  ListTableViewController.swift
//  CheckTheList
//
//  Created by Melanie MacDonald on 2018-11-26.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit
import os.log

class ListTableViewController: UITableViewController {

    //MARK: Properties
    
    var lists = [List]()
    @IBOutlet weak var edit: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hook up edit button to use default API
        edit = editButtonItem
        
        // TODO: display saved items from firebase
        loadSampleItems()
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
        // TODO: Handling for completion, existence of participants
        if list.participants.count == 0 {
            cell.participantFlag.isHidden = true
        }

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
            // Delete the row from the data source
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
            
            let selectedItem = lists[indexPath.row]
            tasksViewController.checklist = selectedItem
        default:
            fatalError("Unexpected Segue Identifer; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ListViewController, let
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
            //saveItems()
        }
    }
    
    //MARK: Private Methods
    
    private func loadSampleItems() {
        guard let list1 = List(name: "Default item", descr: "Here are some notes", dueDate: Date(), participants: []) else {
            fatalError("Unable to instantiate list item1")
        }
        
        guard let list2 = List(name: "Default item2", descr: "Here are some more notes", dueDate: Date(), participants: ["user1", "user2", "user3"]) else {
            fatalError("Unable to instantiate list item2")
        }
        lists += [list1, list2]
    }
    
    // Converts a Date object into a readable String
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
}
