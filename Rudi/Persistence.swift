//
//  Persistence.swift
//  Rudi
//
//  Created by Kurt Höblinger on 26.09.20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    /*
     The XCode generate Persistence.swift generates code here that puts
     dummy data into the container.
     
     This bit of code was deleted.
     */

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        /*
         AppGroup additions
         
         1. define the AppGroup
         2. define the name of the database (<name>.xcdatamodeld)
         3. get the AppGroup's file container
         5. get the URL to the file container
         6. create a persistent container
         7. create a store description containing the url to the file container
         8. point the persistent container to the store in the AppGroups file container
         9. continue like without AppGroups
         
         Why all this? because you could decide to use the app's local persistent container and use
         the AppGroup's file container for something else. Of course,
         
         let container = NSPersistentContainer(name: "SomeName", location: "group.some.identifier")
         
         would be too much to ask...
         */
        
        let appGroup = "group.com.nitricware.Rudi"
        let databaseName = "Rudi"
        
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        let containerURL = fileContainer.appendingPathComponent("\(databaseName).sqlite")
        
        container = NSPersistentContainer(name: "Rudi")
        let storeDescription = NSPersistentStoreDescription(url: containerURL)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = containerURL
        } else {
            container.persistentStoreDescriptions = [storeDescription]
        }
        
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        //let container = NSPersistentContainer(name: "Rudi")
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
    }
}
