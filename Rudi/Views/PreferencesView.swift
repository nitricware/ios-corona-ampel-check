//
//  PreferencesView.swift
//  Rudi
//
//  Created by Kurt Höblinger on 26.09.20.
//

import SwiftUI
import WidgetKit

struct PreferencesView: View {
    /*
     Why is
        @Environment(\.managedObjectContext) private var viewContext
     missing here?
     
     Because this view is just a content view of the Navigation view
     holding this @Environment variable. It's created in AmpelStartView.swift
     */
    
    /*
     This fetch request holds the data for the form.
     Like magic, items holds the fetched results.
     */
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Region.name, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Region>
    
    /*
     This @AppStorage is used to preselect the correct value
     in the Picker(). It must hold a value of the same type
     as the Picker().tag() (i.e. Int)
     */
    @AppStorage("myGemeinde", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var selectedGemeinde: String = "0"
    
    var body: some View {
        Form {
            Section(header: Text("MY_MUNICIPALITY")) {
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
                Picker(selection: $selectedGemeinde, label: Text("MUNICIPALITY")) {
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
                                default:
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 5, height: 5)
                            }
                            Text(item.name ?? "UNKNOWN")
                        }.tag(item.gkz!)
                    }
                }
            }
            Section(header: Text("DATENQUELLE")) {
                Text("DATENQUELLE_TEXT")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
            .onAppear(perform: {
                /*
                 This app comes with widgets that need to know when things have changed here.
                 Therefore, WidgetKit is imported which gives me access to WidgetCenter.
                 With the following function, I can simply reload my widget.
                 */
                print("refreshing widget...");
                WidgetCenter.shared.reloadAllTimelines()
            })
        }
        
        .navigationBarTitle(Text("SETTINGS"))
    }
}

// MARK: Preview
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
