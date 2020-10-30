//
//  Rudi.swift
//  Rudi
//
//  Created by Kurt Höblinger on 25.09.20.
//

import Foundation
import CoreData

class Rudi {
    let dataURLRaw: String = "https://corona-ampel.gv.at/sites/corona-ampel.gv.at/files/assets/Warnstufen_Corona_Ampel_Gemeinden_aktuell.json"
    var jsonData: [AmpelDataSet]? = nil
    let persistenceController = PersistenceController.shared
    
    public func fetchData() throws -> Void {
        if let dataURL = URL(string: dataURLRaw) {
            do {
                let json = try Data(contentsOf: dataURL)
                let decoder = JSONDecoder()
                do {
                    self.jsonData = try decoder.decode([AmpelDataSet].self, from: json)
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
    
    public func loadDataIntoCoreData() throws -> Void {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistenceController.container.viewContext.execute(deleteRequest)
            try persistenceController.container.viewContext.save()
            persistenceController.container.viewContext.reset()
            persistenceController.container.viewContext.refreshAllObjects()
        } catch {
            print("welp")
        }
        if let json = jsonData {
            let dataSet = json.first!
            let isoDate = dataSet.Stand

            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from:isoDate)!
            
            UserDefaults(suiteName: "group.com.nitricware.Rudi")?.set(date.timeIntervalSince1970, forKey: "lastDefinition")
            
            for region in dataSet.Warnstufen {
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
        }
        
        UserDefaults(suiteName: "group.com.nitricware.Rudi")?.set(Date().timeIntervalSince1970, forKey: "lastUpdate")
    }
    
    /// getMyGemeinde takes a GKZ (Gemeindekennzahl) and searches for the string in the database. It will then optionally return the found Region.
    /// - Parameter gkz: Gemeindekennzahl
    /// - Throws: If anything goes wrong when accessing the database, an error will be thrown.
    /// - Returns: A Region or nil.
    public func getMyGemeinde(gkz: String?) throws -> Region? {
        if let id = gkz {
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
