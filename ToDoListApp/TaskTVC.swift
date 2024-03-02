//
//  TableController.swift
//  CIS38Lab2_AustinKim
//
//  Created by Austin Kim on 2/8/24.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class TaskTVC: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, CLLocationManagerDelegate, MKMapViewDelegate {
    var firstTime = true;
    // MARK: Variables & Outlets
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    let fetchRequestCats: NSFetchRequest<ToDoCats> = {
        return ToDoCats.fetchRequest();
    }();
    let fetchRequestTasks: NSFetchRequest<ToDoItemMO> = {
        return ToDoItemMO.fetchRequest()
    }();
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    let sortDescriptor2 = NSSortDescriptor(key: "completed", ascending: false)
    
    var searchController: UISearchController! = UISearchController(searchResultsController: nil);
    var searchResults : [ToDoItemMO] = [];
    
    
    // MARK: - View Control
    var ToDoItems : [ToDoItemMO] = [];
    var fetchedResultsController : NSFetchedResultsController<ToDoItemMO>!;
    
    @IBOutlet weak var nav: UINavigationItem!
    
    var filterButton: UIBarButtonItem!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the needed task
        fetchAllTasks();
        
        // Adding option to filter if object exist
        if navigationItem.leftBarButtonItem == nil {
            filterButton = UIBarButtonItem(title: "Filter", image: nil, primaryAction: nil, menu: nil)
            navigationItem.leftBarButtonItem = filterButton
        }
        
        // Set the search bar up
        initSearchBar();
        
        // Update filter menu
        updateCategoryMenu();
        
        // Handler when need to update Filter Cat Menu
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategoryMenu), name: NSNotification.Name("CatUpdate"), object: nil)
        // Handler for fetching & updating tasks
        NotificationCenter.default.addObserver(self, selector: #selector(fetchAllTasks), name: NSNotification.Name("CatDelete"), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: Search Functionality
    func initSearchBar(){
        self.searchController.searchBar.sizeToFit();
        self.searchController.hidesNavigationBarDuringPresentation = false;
        self.searchController.searchResultsUpdater = self;
        self.searchController.obscuresBackgroundDuringPresentation = false;
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let textSearch = searchController.searchBar.text {
            filterContentForSearchText(text: textSearch)
            tableView.reloadData();
        }
    }
    
    func filterContentForSearchText(text: String){
        if text.isEmpty{
            searchResults = ToDoItems;
            return;
        }
        searchResults = ToDoItems.filter({ (item: ToDoItemMO) -> Bool in
            let nameMatch = item.name?.range(of: text, options: String.CompareOptions.caseInsensitive)
            return nameMatch != nil;
        })
    }
    
    // MARK: Helper functions
    func handleCheckMark(category: String?, taskName: String?) {
        guard let category = category, let taskName = taskName else {
            print("tasks out of sync")
            return
        }
        
        // Find the task by category and name
        if let taskIndex = ToDoItems.firstIndex(where: { $0.cat == category && $0.name == taskName }) {
            let task = ToDoItems[taskIndex]
            task.completed = !task.completed
            appDelegate.saveContext()
            
            // Reload sections or the specific rows to reflect the change
            let indexPath = IndexPath(row: taskIndex, section: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        } else {
            print("task not found somehow")
        }
    }

    
    
    /**
     Updates the Menu of Filter
     */
    @objc func updateCategoryMenu() {
        print("Updating Category Menu")
        let categories: [String]! = fetchCategories();
        
        // Added handlers to apply the filter to category.
        var actions: [UIAction] = categories.map { category in
            UIAction(title: category, handler: { _ in
                self.applyFilter(category: category)
                self.nav.title = category;
            })
        }
        
        // Action to remove the filter (Show All Tasks)
        let clearAction = UIAction(title: "Clear Filter", attributes: .destructive) { _ in
            // Fetch all tasks
            self.fetchAllTasks()
            
            // Reset the Nav Title
            self.nav.title = "All Tasks"
        }
        // Add this as last option in context menu
        actions.append(clearAction)
        
        // New UIMenu to display Categories followed by clearing option
        let categoriesMenu = UIMenu(title: "Filter by Category", children: actions)
        
        // Set the menu
        filterButton.menu = categoriesMenu;
    }
    
    /**
     Fetches categories and maps then to a string array
     Returns: [String]
     */
    func fetchCategories() -> [String] {
        do {
            let categories = try appDelegate.persistentContainer.viewContext.fetch(fetchRequestCats)
            let categoryNames = categories.compactMap { $0.name }
            return categoryNames
        } catch {
            print("Could not fetch categories: \(error)")
            return []
        }
    }
    
    func applyFilter(category: String) {
        // If task name has the same category name as filter
        fetchRequestTasks.predicate = NSPredicate(format: "cat.name == %@", category)
        
        // Sort the tasks - if not already sorted
        fetchRequestTasks.sortDescriptors = [sortDescriptor, sortDescriptor2]
        
        // Reload table data to show filter
        do {
            // Set the table array correctly
            ToDoItems = try appDelegate.persistentContainer.viewContext.fetch(fetchRequestTasks)
            
            // Reload table to show filtered
            tableView.reloadData()
        } catch {
            print("Could not fetch tasks for category \(category): \(error)")
        }
    }
    
    
    @objc func fetchAllTasks(){
        // Sort if not already sorted
        fetchRequestTasks.sortDescriptors = [sortDescriptor, sortDescriptor2];
        // Remove filter
        fetchRequestTasks.predicate = nil;
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
            let context = appDelegate.persistentContainer.viewContext;
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequestTasks, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil);
            
            do{
                try fetchedResultsController.performFetch()
                if let fetchedObjects = fetchedResultsController.fetchedObjects {
                    // Set the array with new objects.
                    ToDoItems = fetchedObjects
                    
                    // Reload the table with new data
                    tableView.reloadData();
                }
            }catch {
                print (error)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true;
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResults.count;
        }
        
        return ToDoItems.count;
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "TaskCell";
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CellTVC;
        var item = ToDoItems[indexPath.row];
        
        if searchController.isActive {
            item = searchResults[indexPath.row];
        }
        
        // Load Task Name
        cell.titleLabel?.text = item.name;
        
        // Load Date
        let dateFormatter = DateFormatter();
        
        if item.allDay {
            dateFormatter.dateFormat = "MMMM dd yyyy"
        } else {
            dateFormatter.dateFormat = "MMMM dd yyyy hh:mm a"
        }
        cell.dueDateLabel?.text = dateFormatter.string(from: item.date!);
        
        cell.imageView?.clipsToBounds = true;
        cell.imageView?.layer.masksToBounds = true;
        
        // Load Checkmark button should have handler
        cell.checkButton.setImage(UIImage(systemName: item.completed ? "checkmark.square" : "square"), for: .normal)
        cell.checkButtonHandler = { [weak self, weak item] in
               self?.handleCheckMark(category: item?.cat, taskName: item?.name)
        }
        
        // Load category label
        cell.catLabel.text = item.cat;
        
        // Load icons
        let fetchRequest: NSFetchRequest<ToDoCats> = ToDoCats.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", item.cat ?? "")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            do {
                let categories = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
                if let category = categories.first {
                    // Determine the icon: task's icon, category's default icon, or fallback
                    let iconName = item.icon?.isEmpty ?? true ? category.defaultIcon : item.icon
                    let iconImage = UIImage(systemName: iconName ?? "") ?? UIImage(systemName: "questionmark.circle")
                    cell.icon.image = iconImage;
                }
            } catch {
                print("Error fetching category for task: \(error)")
                // Consider how to handle errors or missing categories
            }
        }
        
        if firstTime{
            cell.alpha = 0;
            
            var tran: CATransform3D = CATransform3DIdentity;
            tran = CATransform3DTranslate(tran, -250, 0, 0)
            cell.icon.layer.transform = tran
            UIView.animate(withDuration: 2, animations:{
                cell.icon.layer.transform = CATransform3DIdentity;
                cell.alpha = 1;
            })
        
            if indexPath.row == ToDoItems.count - 1{
                firstTime = !firstTime;
            }
        }
        
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let toDelete = ToDoItems[indexPath.row];
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return };
            let context = appDelegate.persistentContainer.viewContext;
            
            context.delete(toDelete)
            ToDoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade);
        } else if editingStyle == .insert{
            // TODO: Handle insertion
            
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "TaskFeature":
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let vc = segue.destination as! TaskVC;
                let item = ToDoItems[indexPath.row];
                
                // Load strings
                vc.strHeader = item.name;
                vc.strDesc = item.desc;
                
                // Load Date
                let dateFormatter = DateFormatter()
                
                if item.allDay {
                    dateFormatter.dateFormat = "MMMM dd yyyy"
                } else {
                    dateFormatter.dateFormat = "MMMM dd yyyy hh:mm a"
                }
                vc.strDate = "Complete By: " + dateFormatter.string(from: item.date!);
                
                dateFormatter.dateFormat = "MMMM dd yyyy"
                vc.strCreatedOn = "Created On: " +  dateFormatter.string(from: item.createdOn ?? Date());
                vc.strNavTitle = item.cat;
                vc.lon = item.lon;
                vc.lat = item.lat;
                
                // Load icons
                let fetchRequest: NSFetchRequest<ToDoCats> = ToDoCats.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "name == %@", item.cat ?? "")
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    do {
                        let categories = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
                        if let category = categories.first {
                            // Determine the icon: task's icon, category's default icon, or fallback
                            let iconName = item.icon?.isEmpty ?? true ? category.defaultIcon : item.icon
                            let iconImage = UIImage(systemName: iconName ?? "") ?? UIImage(systemName: "questionmark.circle")
                            vc.imgImage = iconImage;
                        }
                    } catch {
                        print("Error fetching category for task: \(error)")
                        // Consider how to handle errors or missing categories
                    }
                }
                
            }
            break;
        case "AddTask":
            let vc = segue.destination as! AddTaskVC;
            vc.taskAdded = {[weak self] in // Callback function
                self?.fetchAllTasks(); // Fetch again after added
            }
            break;
        default:
            break;
        }
    }
    
    
}
