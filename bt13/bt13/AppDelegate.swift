//
//  AppDelegate.swift
//  bt13
//
//  Created by Unima-TD-04 on 1/4/17.
//  Copyright © 2017 Unima-TD-04. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController(nibName: "ViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "bt13")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var writerCT: NSManagedObjectContext = {
        let writerCT = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        writerCT.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        return writerCT
    }()
    
    lazy var mainCT: NSManagedObjectContext = {
        
        let mainCT = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainCT.parent = self.writerCT
        self.mainCT.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        
        return mainCT
    }()
    
    
    var backgroundCT: NSManagedObjectContext {
        let backgroundCT = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundCT.parent = self.mainCT
        self.backgroundCT.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        
        return backgroundCT
    }
    
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

