//
//  CategoryController.swift
//  ToDoListApp
//
//  Created by Austin Kim on 3/1/24.
//

import UIKit
import CoreData

class CategoryTVC: UITableViewController {
    var categories: [ToDoCats] = [];
    
    func fetchCategories() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ToDoCats> = ToDoCats.fetchRequest()
        
        // Sort Alphabetically
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            // Set the arrray with new Data
            categories = try context.fetch(fetchRequest)
            // Reload the table
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch categories every time the view appears
        fetchCategories()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "catCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let category = categories[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let categoryToDelete = categories[indexPath.row]
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            
            // Fetch to check if categories contain any Tasks
            let fetchRequest: NSFetchRequest<ToDoItemMO> = ToDoItemMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "cat == %@", categoryToDelete.name!)
            
            
            do {
                let tasks: [ToDoItemMO] = try context.fetch(fetchRequest)
                print(tasks)
                
                if !tasks.isEmpty {
                    // There's tasks so warn user
                    let alert = UIAlertController(title: "Delete Category", message: "This category has associated tasks. Deleting it will also remove those tasks. Are you sure you want to proceed?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                        self.deleteCategory(category: categoryToDelete, at: indexPath, in: context, toDelete: tasks)
                    }))
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                } else {
                    // No tasks in cat, just delete it
                    deleteCategory(category: categoryToDelete, at: indexPath, in: context)
                }
                
                try context.save()
                NotificationCenter.default.post(name: NSNotification.Name("CatUpdate"), object: nil)
            } catch {
                print("Could not save context after deleting category: \(error)")
            }
        }
    }
    
    func deleteCategory(category: ToDoCats,
                        at indexPath: IndexPath,
                        in context: NSManagedObjectContext,
                        toDelete tasks: [ToDoItemMO] = []) {
        print("Deleting")
        print(tasks)
        if !tasks.isEmpty{
            for task in tasks {
                context.delete(task)
            }
        }
        context.delete(category)
        categories.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        do {
            try context.save()
            // Updates Filter Menu After Deleting
            NotificationCenter.default.post(name: NSNotification.Name("CatUpdate"), object: nil)
            // Updates Tasks Menu After Deleting
            NotificationCenter.default.post(name: NSNotification.Name("CatDelete"), object: nil)
        } catch {
            print("Could not save context after deleting category: \(error)")
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCat"{
            let vc = segue.destination as! AddCatController;
            vc.catAdded = {[weak self] in // Callback function
                self?.fetchCategories(); // Fetch again after added
                NotificationCenter.default.post(name: NSNotification.Name("CatUpdate"), object: nil)
            }
        }
    }
    
    
    
    
    
}
