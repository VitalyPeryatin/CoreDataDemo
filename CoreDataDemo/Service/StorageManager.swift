//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Виталий on 11.03.2021.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext(onSuccess: () -> () = {}) {
        if context.hasChanges {
            do {
                try context.save()
                onSuccess()
            } catch let error {
                context.rollback()
                print(error.localizedDescription)
            }
        }
    }
    
    func save(_ taskName: String, onComplete: (Task) -> ()) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.name = taskName
        
        saveContext() {
            onComplete(task)
        }
    }
    
    func fetchData(onResult: ([Task]) -> ()) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let taskList = try context.fetch(fetchRequest)
            onResult(taskList)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func delete(_ task: Task, onComplete: () -> ()) {
        context.delete(task)
        saveContext() {
            onComplete()
        }
    }
    
    func renameTask(_ task: Task, to newTaskName: String, onComplete: () -> ()) {
        task.name = newTaskName
        saveContext() {
            onComplete()
        }
    }
}
