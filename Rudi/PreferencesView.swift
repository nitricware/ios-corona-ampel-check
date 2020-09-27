//
//  PreferencesView.swift
//  Rudi
//
//  Created by Kurt Höblinger on 26.09.20.
//

import SwiftUI
import WidgetKit

struct PreferencesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Region.name, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Region>
    
    let rudi = Rudi()
    
    /*
     At first, I wasn't sure if @AppStorage can handle
     AppGroups - although I figured it MUST becuase AppGroups
     are somewhat ubiquitous.
     Especially now that iOS 14 Widgets are all over the Place.
     
     Here's how you do it: You simple tell @AppStorage the store
     you want to use. This is great since one App can support
     multiple AppGroups.
     */
    @AppStorage("myGemeinde", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var selectedGemeinde: String = "0"
    
    var body: some View {
        Form {
            Section(header: Text("Meine Gemeinde")) {
                /*
                 PUH, that Picker() took me a while! Here's what I found out:
                 1. a Picker() - or any form element, I suppose - works best with @AppStorage
                 2. @AppStorage works with AppGroups (see comment above)
                 3. You need a .tag() attached to the list item (a HStack{} here, but
                    it could also be a Text() element in a more simple incarnation
                 4. Optionals and Non-Optionals don't match
                    - @AppStorage delivers a non-optional value
                    - ForEach() delivers optional values
                    - the selection: non-optional will ignore an optional .tag()
                 
                 But once you grasp that all, this is a very sleek way to do a preferences pane.
                 */
                Picker(selection: $selectedGemeinde, label: Text("Gemeinde")) {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            switch item.warnstufe {
                                case "1":
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 5, height: 5)
                                case "2":
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 5, height: 5)
                                case "3":
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 5, height: 5)
                                case "4":
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 5, height: 5)
                                case .none:
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 5, height: 5)
                                case .some(_):
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 5, height: 5)
                            }
                            Text("\(item.name ?? "unbekannt")")
                        }.tag(item.gkz!)
                    }
                }
            }
            Section(header: Text("Datenquelle")) {
                Text("BMSGPK, Österreichisches COVID-19 Open Data Informationsportal (https://www.data.gv.at/covid-19)")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
            .onAppear(perform: {
                /*
                 This app comes with widgets that need to know when things have changed here.
                 Therefore, WidgetKit is imported which gives me access to WidgetCenter.
                 With the following function, I can simply reload my widget.
                 */
                WidgetCenter.shared.reloadAllTimelines()
            })
        }
        
        .navigationBarTitle(Text("Einstellungen"))
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
