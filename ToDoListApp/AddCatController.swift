//
//  AddCatController.swift
//  ToDoListApp
//
//  Created by Austin Kim on 3/1/24.
//

import UIKit
import CoreData


class AddCatController: UIViewController {
    var catAdded: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: CATEGORY CONTROLLER
    
    @IBOutlet weak var catName: UITextField!
    @IBAction func discardButton(_ sender: Any) {
        self.dismiss(animated: true);
    }
    @IBOutlet weak var defaultIcon: UITextField!
    
    
    
    @IBAction func insertCategory(_ sender: Any) {
        guard let categoryName = catName.text?.trimmingCharacters(in: .whitespaces), !categoryName.isEmpty else {
            present(showAlert("Field Missing", "Name field is required."), animated: true);
            return;
        }
        // SF Symbol check
        guard let iconString = defaultIcon.text, !iconString.isEmpty, UIImage(systemName: iconString) != nil else {
               present(showAlert("Invalid Icon", "Please provide a valid SF Symbol name for the icon."), animated: true)
               return
           }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ToDoCats> = ToDoCats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", categoryName.capitalized)

        do {
            let existingCategories = try context.fetch(fetchRequest)
            
            if existingCategories.isEmpty {
                let newCategory = ToDoCats(context: context)
                newCategory.name = categoryName.capitalized;
                newCategory.defaultIcon = iconString;
                newCategory.createdOn = Date();
                
                try context.save()
                print("Category added successfully.")
                
                // Respond to callback
                catAdded?();
                
                self.dismiss(animated: true)
            } else {
                // An existing category with the same name was found
                present(showAlert("Duplicate Category", "A category with the same name already exists."), animated: true)
            }
        } catch {
            print("Failed to save the category: \(error)")
            present(showAlert("Something Went Wrong!", "An unknown error has occured."), animated: true);
            
        }
        
    }
    
    /**
     Helper function, allows to display error message dialog.
     From Lab 1C
     */
    func showAlert(_ title: String,_ message: String) -> UIAlertController {
        let alertBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertBox
    }
    
    
}
