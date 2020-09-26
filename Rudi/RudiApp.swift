//
//  RudiApp.swift
//  Rudi
//
//  Created by Kurt Höblinger on 26.09.20.
//

import SwiftUI

@main
struct RudiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
