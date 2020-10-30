//
//  AmpelStartView.swift
//  Rudi
//
//  Created by Kurt Höblinger on 26.09.20.
//

import SwiftUI

struct AmpelStartView: View {
    /*
     This is the context used for persistence (CoreData). This one here
     can be used by all content views of this navigationView.
     */
    @Environment(\.managedObjectContext) private var viewContext
    
    /*
     At first, I wasn't sure if @AppStorage can handle
     AppGroups - although I figured it MUST becuase AppGroups
     are somewhat ubiquitous.
     Especially now that iOS 14 Widgets are all over the Place.
     
     Here's how you do it: You simple tell @AppStorage the store
     you want to use. This is great since one App can support
     multiple AppGroups.
     */
    
    @AppStorage("myGemeinde", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var selectedGemeinde: String?
    @AppStorage("lastDefinition", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var lastDefinition: Double?
    @AppStorage("lastUpdate", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var lastUpdate: Double?
    
    @State public var myGemeinde: Region? = nil
    
    /*
     This var is used to toggle the loading indicator on and off.
     */
    
    @State public var loadingIndicator = false
    
    /*
     Define the default colors of the traffic light.
     
     They must be public because the extension of this view
     uses them and is in another file.
     */
    
    @State public var trafficGreen: Color = .gray
    @State public var trafficYellow: Color = .gray
    @State public var trafficOrange: Color = .gray
    @State public var trafficRed: Color = .gray
    
    /*
     Finally an instance of Rudi is created here.
     */
    
    let rudi = Rudi()
    
    /*
     Showing multiple different errors in SwiftUI is easier than expected.
     Create a @State that toggles the visibility of the alert message.
     Also, create a @State holding the type of the message that is to be
     shown.
     */
    
    @State public var alertVisibility: Bool = false
    @State public var alertType: RudiAlertTypes = .generic
    
    /*
     Below, the body of the screen is defined. It contains
     all views for this particular screen.
     */
    
    var body: some View {
        /*
         The views relevant for this screen are wrapped in a
         NavigationView. That gives us a headline that just
         fits into the iOS loom and feel.
         */
        NavigationView {
            /*
             Using a VStack or a HStack allows us to hand over all
             alignment logic to iOS.
             */
            VStack {
                /*
                 This Text() element will display whatever is stored in the
                 @State variable myGemeinde. This is set in a function that
                 was created as an extension to this view.
                 
                 If myGemeinde is nil "Keine Gemeinde" will be displayed.
                 
                 The function in the extension explains when myGemeinde
                 could be nil.
                 
                 Finally .font(.headline) styles the Text() in a way that
                 makes it look like a headline.
                 */
                Text(myGemeinde?.name ?? "Keine Gemeinde")
                    .font(.headline)
                
                /*
                 This HStack contains four circles. Each one is one light
                 of a traffic light. The .trafficLight() modifier for Circle()
                 does not exist out of the box of course, but was created
                 in another extension. This modifier aks for a fill color and
                 a line color. fillColor uses a @State variable.
                 */
                HStack {
                    Circle()
                        .trafficLight(
                            fillColor: trafficRed,
                            lineColor: Color.red
                        )
                    Circle()
                        .trafficLight(
                            fillColor: trafficOrange,
                            lineColor: Color.orange
                        )
                    Circle()
                        .trafficLight(
                            fillColor: trafficYellow,
                            lineColor: Color.yellow
                        )
                    Circle()
                        .trafficLight(
                            fillColor: trafficGreen,
                            lineColor: Color.green
                        )
                    
                }
                
                /*
                 This VStack contains further information about the situation
                 in the selected municipality.
                 */
                VStack {
                    /*
                     Again, if myGemeinde is nil, different things will happen.
                     
                     The title that has the .font() of a .title will just say
                     "Warnstufe 0".
                     
                     The text below will encourage the user to stay safe.
                     
                     If however, the situation is 1,2,3 or 4 the matching text,
                     as defined by the minitry will be shown.
                     
                     For a better viewing experience .padding() is added.
                     */
                    Text("Warnstufe \(myGemeinde?.warnstufe ?? "0")")
                        .font(.title)
                    switch (myGemeinde?.warnstufe ?? "0") {
                    case "1":
                        Text("WARN_1")
                    case "2":
                        Text("WARN_2")
                    case "3":
                        Text("WARN_3")
                    case "4":
                        Text("WARN_4")
                    default:
                        Text("WARN_0")
                    }
                }.padding()
                
                /*
                 This VStack shows three Text() and a button. The Text()
                 work quite magical I'd say. The format and display a date
                 inline with a regular string.
                 
                 How is it done? It uses something called string interpolation.
                 This string interpolation takes several arguments. Here,
                 argument 1 is the Date() - but it could in a different case simply
                 be an Int - and argument 2 is the formatter.
                 
                 The Date() is initialized with lastUpdate which is a Double right
                 from the @AppStorage - OR 0.0 if lastUpdate is nil (on the
                 first lauch i.e.) - that counts the seconds since 1970. It's set once
                 Rudi() fetched an update of the date in Rudi.swift.
                 
                 The formatter is, once again, an extenion to this Struct.
                 
                 The second Text() does exactly the same but with a different Double.
                 
                 The button triggers the sync function which happens to be placed in
                 an extension of this Struct. The label is somewhat dynamic.
                 */
                VStack {
                    Text("Letzte Aktualisierung: \(Date(timeIntervalSince1970: lastUpdate ?? 0.0), formatter: Self.updateDateFormat)")
                            .font(.caption)
                    Text("Datenstand: \(Date(timeIntervalSince1970: lastDefinition ?? 0.0), formatter: Self.updateDateFormat)").font(.caption)
                    Button(action: {
                        sync()
                    }, label: {
                        /*
                         When sync() starts the @State variable loadingIndicator is
                         set to true. The label knows this and shows a ProgressView().
                         At the end of sync() the @State variable loadingIndicator
                         is set to false again and the label shows a Text().
                         
                         Further down you see that the loadingIndicator @State also makes
                         this button clickable (enabled) or not (disabled)
                         */
                        if loadingIndicator {
                            ProgressView()
                        } else {
                            Text("Aktualisieren")
                        }
                    }).disabled(loadingIndicator)
                }.padding()
            }.padding()
                
            /*
             The .navigationBarTitle() must be set here and NOT outside the content
             of a NavigationBar because we defined the contents (and the title is part
             of the content) within the curly brackets.
             
             The .navigationBarItems are just like the tile.
             
             If any of those would be defined outside, they would not show up at all.
             
             Whenever the NavigationView appears, the function start is performed.
             This function is located in the extension of this view.
             */
            .navigationBarTitle(Text("Warnstufen-Ampel"))
            .navigationBarItems(trailing:
                NavigationLink(
                    destination: PreferencesView().environment(\.managedObjectContext, viewContext),
                    label: {
                        Text("SETTINGS")
                    }
                ).disabled(loadingIndicator)
            )
            .onAppear(perform: start)
        }
        .alert(isPresented: $alertVisibility, content: {
            switch alertType {
            case .coreDataError:
                return Alert(title: Text("DB_ERROR"))
            case .jsonError:
                return Alert(title: Text("JSON_ERROR"))
            default:
                return Alert(title: Text("UNEXPECTED_ERROR"))
            }
            
        })
    }
}

/*
 MARK: Preview
 This makes the preview in XCode work.
 */
struct AmpelStartView_Previews: PreviewProvider {
    static var previews: some View {
        AmpelStartView()
    }
}
