//
//  DatabaseController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 24/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData

public class DatabaseController {
    
    // Prevent instance
    private init(){}
    
    public static let sharedInstance: DatabaseController = {
        let instance = DatabaseController()
        return instance
    }()
    
    // MARK: - Core Data stack
    
    private lazy var applicationDocumentsDirectory: NSURL = { // private fordi vi ikke vil at andre skal ha tilgang til filene
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // gir oss manageren som vanligvis brukes til å manage filsystemet
        // første er mappen vi skal
        // andre sier at vi bruker brukeres home directory
        
        return urls[urls.index(before: urls.endIndex)] as NSURL
        //return urls[urls.endIndex.predecessor()] // returnerer første tomme celle i array, og så predecessor returnerer den før dette. så om vi har et array av 5 elementer, returneres nå nummer 4 siden vi også teller med 0
    }() //en link til der directoryen er
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "workoutApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        // bruker her unwrapped selv om det er unsafe, fordi om vi ikke finner data, så vil vi at appen skal crashe uansett
    }()
    
    // legger til en coordinator som kjenner til manageObjectModelen
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        //coordinatoren må vite hvor data skal lagres
        let url = self.applicationDocumentsDirectory.appendingPathComponent("workoutApp.sqlite")
        
        //lager en persistance store for oss når vi launcher appen første gang?
        
        do {
            
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil) //sender inn urlen vi laget til directory  og greier
            
            //Hvis dette virker, uten error har vi en coordinator med en model, og en persistance, lagret som en SQLite database. Hvis vi får error trigges catch closuren
        } catch { // Catch statements inneholder alltid automatisk en error
            
            let userInfo: [String: AnyObject] = [ NSLocalizedDescriptionKey: "Failed to initialize the application's saved data" as AnyObject, NSLocalizedFailureReasonErrorKey: "There was an error creating or loading the application's saved data" as AnyObject, NSUnderlyingErrorKey: error as NSError
            ]
            
            let wrappedError = NSError(domain: "com.teambizniz.alexander", code: 9999, userInfo: userInfo)
            
            print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            abort()//når vi sender appen til brukeren må vi gjøre noe med koden, men her skal vi bare terminere appen og logge erroren.
        }
        
        return coordinator
    }()
    
    public lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
        
        // managedObjectContext gjøres lazy public, fordi vi skal bare lage en, og den skal kun lages når vi først trenger den. Er ikke hver gang vi bruker appen vi trenger å oppdatere context og videre til persistent store feks.
        
    }()
    
    public class func getContext() -> NSManagedObjectContext {
//        return persistentContainer.viewContext
        return sharedInstance.managedObjectContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "workoutApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = DatabaseController.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func clearCoreData() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Workout.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try sharedInstance.managedObjectContext.execute(deleteRequest)
        } catch _ {
            print("error clearing core data before seeding")
        }    
    }
    
    // MARK: - Entity management
    
    static func createManagedObjectForEntity(_ entity: Entity) -> NSManagedObject? {
        // Helpers
        let context = sharedInstance.managedObjectContext
        var result: NSManagedObject?
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity.rawValue, in: context)
        
        // Unwrap and create Managed Object
        if let entityDescription = entityDescription {
            result = NSManagedObject(entity: entityDescription, insertInto: context)
        }
        
        return result
    }
    
    static func fetchManagedObjectsForEntity(_ entity: Entity) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        let managedObjectContext = sharedInstance.managedObjectContext
        
        // Helpers
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let objects = try managedObjectContext.fetch(fetchRequest)
            
            if let objects = objects as? [NSManagedObject] {
                result = objects
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        return result
    }
}

 
