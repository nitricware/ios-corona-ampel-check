//
//  AmpelStartViewExtension.swift
//  Rudi
//
//  Created by Kurt Höblinger on 02.10.20.
//

import Foundation
import SwiftUI

/*
 This extension holds functions and formatters the
 AmpelStartView uses.
 
 You could also integrate all this into AmpelStartView
 either directly or as an extension into AmpelStartView.swift
 but for readability this portion of the code lies here.
 
 The @State variables in AmpelStartView.swift are set to
 public because of this outsourcing. The different file
 makes the difference.
 */
extension AmpelStartView {
    
    /*
     This is the formatter used by the Text() string
     interpolation
     */
    static let updateDateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "d. M. yyyy"
            return formatter
        }()
    
    /*
     This funcion is called when AmpelStartView becomes
     visible. It determines wheter data must be fetched and
     does this if necessary. Also, it populates the
     myGemeinde @State variable and switches the
     traffic light to the appropriate color.
     */
    
    /// Performs various operation when view shows
    func start() {
        if (Date(timeIntervalSince1970: lastUpdate ?? 0.0).addingTimeInterval(86400) <= Date()) {
            // The last update happened at least 24 hours (86400 seconds) ago
            sync()
        }
        
        do {
            try getMyGemeinde()
        } catch {
            alertVisibility = true
            alertType = .coreDataError
        }
        switchTrafficLight()
    }
    
    /*
     This function changes the colors of the traffic
     light according to the current threat level in
     the region. If myGemeinde is nil a fictional
     threat level 0 is set.
     */
    
    /// Switches traffic lights accordingly
    func switchTrafficLight() {
        trafficGreen = .gray
        trafficYellow = .gray
        trafficOrange = .gray
        trafficRed = .gray
        switch (myGemeinde?.warnstufe ?? "0") {
        case "1":
            trafficGreen = .green
        case "2":
            trafficYellow = .yellow
        case "3":
            trafficOrange = .orange
        case "4":
            trafficRed = .red
        default:
            trafficGreen = .gray
        }
    }
    
    /*
     Based on a value set in @AppStorage, the Region() is
     loaded from the database and the @State variable
     myGemeinde is set.
     */
    func getMyGemeinde() throws -> Void{
        myGemeinde = try rudi.getMyGemeinde(gkz: selectedGemeinde)
    }
    
    /*
     This function triggers the download of the most recent
     data from the government server and saves that to the database.
     */
    func sync() {
        loadingIndicator = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try rudi.fetchData()
                
                /*
                 CoreData stuff must happen on the thread the context was loaded in.
                 In this case, it's bound to the main thread.
                 compare: https://developer.apple.com/documentation/coredata/using_core_data_in_the_background
                 */
                DispatchQueue.main.async {
                    do {
                        try rudi.loadDataIntoCoreData()
                        loadingIndicator = false
                    } catch {
                        alertVisibility = true
                        alertType = .coreDataError
                    }
                }
            } catch {
                alertVisibility = true
                alertType = .jsonError
            }
        }
    }
}
