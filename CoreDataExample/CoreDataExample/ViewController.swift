//
//  ViewController.swift
//  CoreDataExample
//
//  Created by Hasan Akoglu on 05/07/2021.
//

import CoreData
import UIKit

/**
 HOW TO USE CORE DATA IN SWIFT
 
 - Core Data provides on-disk persistence, which means your data will be accessible even after terminating your app or shutting down your device. This is different from in-memory persistence, which will only save your data as long as your app is in memory, either in the foreground or in the background.
 
 - Xcode comes with a powerful Data Model editor, which you can use to create your managed object model.
 - A managed object model is made up of entities, attributes and relationships
 - An entity is a class definition in Core Data.
 - An attribute is a piece of information attached to an entity.
 - A relationship is a link between multiple entities.
 - NSManagedObject is a run-time representation of a Core Data entity. You can read and write to its attributes using Key-Value Coding.
 - You need an NSManagedObjectContext to save() or fetch(_:) data to and from Core Data.
 
 */

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "The List"
        tableView.register(UITableViewCell.self,
                             forCellReuseIdentifier: "Cell")
    }
    
    //fetching core data
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      //1- you need a managed object context
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      //2- NSFetchRequest is the class responsible for fetching from Core Data
      let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Person")
      
      //3- You hand the fetch request over to the managed object context to do the heavy lifting
      do {
        people = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }

    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name",
                                        message: "Add a new name",
                                        preferredStyle: .alert)
          
        let saveAction = UIAlertAction(title: "Save", style: .default) {
          [unowned self] action in
          
          guard let textField = alert.textFields?.first,
            let nameToSave = textField.text else {
              return
          }
          
          self.save(name: nameToSave)
          self.tableView.reloadData()
        }
          
          let cancelAction = UIAlertAction(title: "Cancel",
                                           style: .cancel)
          
          alert.addTextField()
          
          alert.addAction(saveAction)
          alert.addAction(cancelAction)
          
          present(alert, animated: true)
    }
    
    //saving core data
    func save(name: String) {
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      // 1- you first need to get your hands on an NSManagedObjectContext
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      // 2- You create a new managed object and insert it into the managed object context.
      let entity =
        NSEntityDescription.entity(forEntityName: "Person",
                                   in: managedContext)!
      
      let person = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      // 3- With an NSManagedObject in hand, you set the name attribute using key-value coding. must be exactly the same as set in datamodel
      person.setValue(name, forKeyPath: "name")
      
      // 4- You commit your changes to person and save to disk by calling save on the managed object context.
      do {
        try managedContext.save()
        people.append(person)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
                 -> UITableViewCell {

    let person = people[indexPath.row]
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "Cell",
                                    for: indexPath)
    //you grab the name attribute from the NSManagedObject
    cell.textLabel?.text =
      person.value(forKeyPath: "name") as? String
    return cell
  }
}
