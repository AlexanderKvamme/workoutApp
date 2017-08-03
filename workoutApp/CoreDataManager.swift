////
////  DatabaseManager.swift
////  workoutApp
////
////  Created by Alexander Kvamme on 01/08/2017.
////  Copyright © 2017 Alexander Kvamme. All rights reserved.
////
//
import Foundation
import CoreData
//
///// This class is supposed to be an improvement over my DatabaseController, and follows Bart Jacobs "Mastering Core Data" book. Phase over to using this
//
///*

//final class CoreDataManager {
//    
//    // MARK: - Properties
//    
//    private var modelName: String
//    
//    // MARK: - Initializers
//    
//    init(modelName: String) {
//        self.modelname = modelName
//    }
//}



//
//final class CoreDataManager {
//    
//    // MARK: - Properties
//    
//    private let modelName: String
//    
//    // managedObjectContext
//    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
//        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
//        return managedObjectContext
//    }()
//    
//    // managedObjectModel
//    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
//        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
//            fatalError("unable to find url of managedObjectModel")
//        }
//        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("unable to create managedObjectModel")
//        }
//        return managedObjectModel
//    }()
//    
//    // persistentStoreCoordinator
//    private(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//        let persistentStoreCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        
//        // Helpers
//        let fileManager = FileManager.default
//        let storeName = "\(self.modelName).sqlite"
//        
//        // URL Documents Dicrectory
//        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        
//        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
//        
//        do {
//            // Add persistent store
//            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
//            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
//        } catch let error as NSError {
//            fatalError("Unable to add persistent store")
//        }
//        return persistentStoreCoordinator
//    }()
//    
//    // MARK: - Initializer
//    
//    init (modelName: String) {
//        self.modelName = modelName
//        
//        setupNotificationHandling()
//    }
//    
//    // MARK: - Methods
//    
//    private func setupNotificationHandling() {
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationWillTerminate, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
//    }
//    
//    @objc func saveChanges(_ notification: Notification) {
//        saveChanges()
//    }
//    
//    private func saveChanges() {
//        guard managedObjectContext.hasChanges else {
//            print("managedObjectContext had no changes ")
//            return
//        }
//        
//        do {
//            try managedObjectContext.save()
//            print("save managed object context saved")
//        } catch {
//            print("Unable to save managed object context")
//        }
//    }
//}
//
