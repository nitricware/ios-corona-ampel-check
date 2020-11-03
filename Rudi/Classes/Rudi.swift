//
//  Rudi.swift
//  Rudi
//
//  Created by Kurt Höblinger on 25.09.20.
//

import Foundation
import CoreData

/*
 Rudi is responsible for fetching the data from the
 server, parsing it and doing some database operations.
 */
class Rudi {
    let dataURLRaw: String = "https://corona-ampel.gv.at/sites/corona-ampel.gv.at/files/assets/Warnstufen_Corona_Ampel_Gemeinden_aktuell.json"
    var jsonData: [AmpelDataSet]? = nil
    let persistenceController = PersistenceController.shared
    
    /// Fetches the data from the URL.
    /// - Throws: Could mean that decoding or converting the data failed, or that the URL couldn't be created.
    /// - Returns: Void
    public func fetchData() throws -> Void {
        if let dataURL = URL(string: dataURLRaw) {
            do {
                let dataObject = try Data(contentsOf: dataURL)
                let decoder = JSONDecoder()
                do {
                    self.jsonData = try decoder.decode([AmpelDataSet].self, from: dataObject)
                } catch {
                    throw RudiError.genericError
                }
            } catch {
                throw RudiError.genericError
            }
        } else {
            throw RudiError.genericError
        }
    }
    
    /// Loads the previously fetched data into core data.
    /// - Throws: Could mean that deleting the old data or saving the new data failed.
    /// - Returns: Void
    public func loadDataIntoCoreData() throws -> Void {
        /*
         If jsonData is not nil we know that we heave fetched
         the data and can proceed. If it is nil, we'll abort
         and throw an error.
         */
        if let json = jsonData {
            /*
             Before we can save the moste recent data set to
             our core data database, we must first delete all
             that's currently in there.
             
             Therefore, we fetch everything that is in the
             entity (table) Region and hand that over to a
             NSBatchDeleteRequest.
             
             The we try to execute and save it to the context
             before we reset the context and refresh all objects
             that rely on the context.
             */
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try persistenceController.container.viewContext.execute(deleteRequest)
                try persistenceController.container.viewContext.save()
                persistenceController.container.viewContext.reset()
                persistenceController.container.viewContext.refreshAllObjects()
            } catch {
                throw RudiError.genericError
            }
            
            /*
             Now that that's out of the way, the code can proceed and fill the
             database with the newly acquireed data.
             
             Only the first entry of the array in the dataSet is required.
             The other ones are just old, archived data sets that come
             with the download.
             */
        
            let dataSet = json.first!
            
            /*
             dataSet.Stand holds a string that conforms to an ISO-Date.
             This piece of coed creates a date object from that string.
             
             The date is used to set the UserDefault lastDefinition
             to the correct value. Since UserDefaults can only hold
             primitive types like integers, the seconds since 1970
             are used.
             */
            
            let isoDate = dataSet.Stand

            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from:isoDate)!
            
            UserDefaults(suiteName: "group.com.nitricware.Rudi")?.set(date.timeIntervalSince1970, forKey: "lastDefinition")
            
            /*
             This for loop saves every region that is in the dataSet
             (several thousand) into the database.
             */
            
            for region in dataSet.Warnstufen {
                /*
                 Let's create a new instance of a Region object in the current
                 context and set its fields to the correct value. Then dave the
                 context or throw an error if that fails.
                 
                 One could also replace the line that trows with some code that
                 keeps track of failed attempts and proceed to the next
                 entry in the dataSet.
                 */
                let entry = Region(context: persistenceController.container.viewContext)
                
                entry.gkz = region.GKZ
                entry.name = region.Name
                entry.warnstufe = region.Warnstufe

                do {
                    try persistenceController.container.viewContext.save()
                } catch {
                    throw RudiError.genericError
                }
            }
            
            /*
             Finally, update the UserDefault lastUpdate to now.
             */
            UserDefaults(suiteName: "group.com.nitricware.Rudi")?.set(Date().timeIntervalSince1970, forKey: "lastUpdate")
        } else {
            throw RudiError.genericError
        }
    }
    
    /// getMyGemeinde takes a GKZ (Gemeindekennzahl) and searches for the string in the database. It will then optionally return the found Region.
    /// - Parameter gkz: Gemeindekennzahl
    /// - Throws: If anything goes wrong when accessing the database, an error will be thrown.
    /// - Returns: A Region or nil.
    public func getMyGemeinde(gkz: String?) throws -> Region? {
        /*
         Since gkz is loaded from UserDefaults and that UserDefault
         could potentially not be set yet, the code has to check
         whether gkz is nil or not. If it is nil, this function
         also returns nil.
         */
        if let id = gkz {
            /*
             The code returns the first entry of the fetch request.
             The fetch request tries to get all records from the
             entity (table) "Region" that has the matching gkz in
             its attribute (column) gkz.
             
             If that fails, an error is thrown.
             */
            let request = NSFetchRequest<Region>(entityName: "Region")
            let predicate = NSPredicate(format: "gkz = \(id)")
            request.predicate = predicate
            do {
                let result = try persistenceController.container.viewContext.fetch(request)
                if let region = result.first {
                    return region
                }
            } catch {
                throw RudiError.genericError
            }
        }
        
        return nil
    }
}
