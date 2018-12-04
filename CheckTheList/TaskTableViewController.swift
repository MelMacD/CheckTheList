//
//  TaskTableViewController.swift
//  CheckTheList
//
//  Created by Melanie MacDonald on 2018-11-26.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit
import os.log

class TaskTableViewController: UITableViewController {

    //MARK: Properties
    
    // this is sent from the ListTableViewController
    var checklist: List?
    var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // TODO: display saved items from firebase
        loadSampleItems()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    //TODO: Remove this
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "TaskTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskTableViewCell else {
            fatalError("The dequeued cell is not an instance of ListTableViewCell")
        }
        
        // Fetches the appropriate list
        let task = tasks[indexPath.row]
        
        cell.taskName.text = task.name
        cell.taskDueDate.text = convertDateToString(date: task.dueDate)
        if task.participants.count == 0 {
            cell.participantFlag.isHidden = true
        }
        cell.taskStatus.text = task.status
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
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            //save items
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // MARK: - Navigation
    @IBAction func cancel(_ sender: Any) {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The List View Controller is not inside a navigation controller")
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddTask":
            os_log("Adding a new checklist", log: OSLog.default, type: .debug)
        case "EditTask":
            guard let tasksViewController = segue.destination as? TaskViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? TaskTableViewCell else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItem = tasks[indexPath.row]
            tasksViewController.task = selectedItem
        default:
            fatalError("Unexpected Segue Identifer; \(String(describing: segue.identifier))")
        }
    }

    //MARK: Actions
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TaskViewController, let
            task = sourceViewController.task {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing item
                tasks[selectedIndexPath.row] = task
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new item
                let newIndexPath = IndexPath(row: tasks.count, section: 0)
                tasks.append(task)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the items
            //saveItems()
        }
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
        let sortedList = tasks.sorted {
            let number1 = $0.isCompleted ? 1 : 0
            let number2 = $1.isCompleted ? 1 : 0
            return number1 < number2
        }
        tasks = sortedList
        self.tableView.reloadData()
    }
    
    func sortDueDate() {
        let sortedList = tasks.sorted {
            return $0.dueDate < $1.dueDate
        }
        tasks = sortedList
        self.tableView.reloadData()
    }
    
    func sortTitle() {
        let sortedList = tasks.sorted {
            return $0.name < $1.name
        }
        tasks = sortedList
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
        guard let task1 = Task(name: "Default item", descr: "Here are some notes", dueDate: Date(), participants: [], status: "Available", isCompleted: true) else {
            fatalError("Unable to instantiate list item1")
        }
        
        guard let task2 = Task(name: "Default item2", descr: "Here are some more notes", dueDate: Date(), participants: ["user1", "user2", "user3"], status: "In progress", isCompleted: false) else {
            fatalError("Unable to instantiate list item2")
        }
        tasks += [task1, task2]
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
