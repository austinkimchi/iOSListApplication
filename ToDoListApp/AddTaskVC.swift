//
//  AddViewController.swift
//  ToDoListApp
//
//  Created by Austin Kim on 3/1/24.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class AddTaskVC: UIViewController {
    var myGeoCoder = CLGeocoder();
    
    var taskAdded: (() -> Void)?
    /**
     Helper function, allows to display error message dialog.
     From Lab 1C
     */
    func showAlert(_ title: String,_ message: String) -> UIAlertController {
        let alertBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertBox
    }
    
    // MARK: For Add Task View Controller
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var catField: UIButton!
    @IBOutlet weak var timeField: UIDatePicker!
    @IBOutlet weak var iconField: UITextField!
    @IBOutlet weak var allDay: UISwitch!
    @IBOutlet weak var locationField: UITextField!
    
    
    var NewItem: ToDoItemMO!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fix to align center
        timeField.contentHorizontalAlignment = .center
        
        fetchAndLoadCategories();
    }
    
    
    /**
     When user doesn't hits that discard button in UI it will dismiss the screen.
     */
    @IBAction func discarded(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func formCheck(_ sender: Any) {
        
        if (nameField.text == "" ||
            catField.titleLabel?.text == "Selection Required" ||
            locationField.text == "")
        {
            present(showAlert("Invalid Field", "Please fill out all required fields"), animated: true)
            return;
        }
        
        // create local request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationField.text
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response, error == nil else {
                // Handle not being able to find location
                self.present(self.showAlert("Search Error", "Unable to find the location."), animated: true)
                return
            }
            
            if let item = response.mapItems.first { // Use first result of collection
                let coordinate = item.placemark.coordinate
                
                if let appDel = (UIApplication.shared.delegate as? AppDelegate){
                    // Use model of ToDoItem Managed Object
                    self.NewItem = ToDoItemMO(context: appDel.persistentContainer.viewContext);
                    
                    // Set the model to the fields
                    self.NewItem.name = self.nameField.text!;
                    self.NewItem.cat = self.catField.titleLabel?.text;
                    
                    self.NewItem.desc = self.descField.text ?? "";
                    self.NewItem.icon = self.iconField.text ?? "";
                    self.NewItem.allDay = self.allDay.isOn;
                    self.NewItem.date = self.timeField.date;
                    self.NewItem.createdOn = Date();
                    
                    // Long Lat
                    self.NewItem.lat = (coordinate.latitude);
                    self.NewItem.lon = (coordinate.longitude);
                    
                    // Save model to CoreData
                    appDel.saveContext()
                }
                
                // Callback function
                self.taskAdded?();
                
                // Close window
                self.dismiss(animated: true, completion: nil);
                // Your existing code to create and save the new item...
            } else {
                // Doesn't exist
                self.present(self.showAlert("Location Not Found", "Please try a different search."), animated: true)
            }
        }
        return;
    }
    
    func fetchAndLoadCategories(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ToDoCats> = ToDoCats.fetchRequest()
        
        do {
            let categories = try context.fetch(fetchRequest)
            let menuItems = categories.map { category in
                UIAction(title: category.name ?? "Unknown", handler: { [weak self] _ in
                    self?.catField.setTitle(category.name, for: .normal)
                    // Optionally, save the selected category name
                })
            }
            
            // Assign new menu to the button
            catField.menu = UIMenu(title: "Select Category", children: menuItems)
            catField.showsMenuAsPrimaryAction = true
        } catch {
            print("Could not fetch categories: \(error)")
        }
    }
    
    @IBAction func dayToggled(_ sender: UISwitch, forEvent event: UIEvent) {
        if sender.isOn {
            // TODO: ADD ANIMATION?
            // I don't know how to add animation.
            timeField.datePickerMode = .date;
            return;
        }
        timeField.datePickerMode = .dateAndTime;
    }
    
    
    
    
    /*
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
     
     */
}
