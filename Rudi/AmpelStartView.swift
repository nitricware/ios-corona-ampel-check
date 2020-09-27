//
//  AmpelStartView.swift
//  Rudi
//
//  Created by Kurt Höblinger on 26.09.20.
//

import SwiftUI
import WidgetKit

struct AmpelStartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    /*
     To understand what I did here, see explanation in PreferencesView.swift
     */
    
    @AppStorage("myGemeinde", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var selectedGemeinde: String?
    @AppStorage("lastDefinition", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var lastDefinition: Double?
    @AppStorage("lastUpdate", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var lastUpdate: Double?
    
    @State private var myGemeinde: Region? = nil
    
    @State private var loadingIndicator = false
    
    @State private var trafficGreen: Color = .gray
    @State private var trafficYellow: Color = .gray
    @State private var trafficOrange: Color = .gray
    @State private var trafficRed: Color = .gray
    
    let rudi = Rudi()
    
    var body: some View {
        NavigationView {
            VStack {
                Text(myGemeinde?.name ?? "Keine Gemeinde")
                .font(.headline)
                HStack {
                    Circle()
                        .fill(trafficRed)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.red, lineWidth: 4)
                        )
                    Circle()
                        .fill(trafficOrange)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.orange, lineWidth: 4)
                        )
                    Circle()
                        .fill(trafficYellow)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.yellow, lineWidth: 4)
                        )
                    Circle()
                        .fill(trafficGreen)
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.green, lineWidth: 4)
                        )
                    
                }
                VStack {
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
                VStack {
                    VStack {
                        
                        Text("Letzte Aktualisierung: \(Date(timeIntervalSince1970: lastUpdate ?? 0.0), formatter: Self.updateDateFormat)")
                                .font(.caption)
                        Text("Datenstand: \(Date(timeIntervalSince1970: lastDefinition ?? 0.0), formatter: Self.updateDateFormat)").font(.caption)
                        Button(action: {
                            sync()
                        }, label: {
                            if loadingIndicator {
                                ProgressView()
                            } else {
                                //Image(systemName: "arrow.clockwise.circle")
                                Text("Aktualisieren").padding()
                            }
                        }).disabled(loadingIndicator)
                    }.padding()
                }
            }.padding()
                
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
    }
}



extension AmpelStartView {
    static let updateDateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "d. M. yyyy"
            //formatter.dateStyle = .medium
            return formatter
        }()
    
    func start() {
        var updateRequired = false
        
        if (Date(timeIntervalSince1970: lastUpdate ?? 0.0).addingTimeInterval(86400) <= Date()) {
            // The last update happened at least 24 hours ago
            updateRequired = true
        }
        
        if updateRequired {
            sync()
        }
        
        getMyGemeinde()
        switchTrafficLight()
    }
    
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
    
    func getMyGemeinde() {
            do {
                myGemeinde = try rudi.getMyGemeinde(gkz: selectedGemeinde)
                //myGemeindeName = myGemeinde.name ?? "Keine Gemeinde"
                //myGemeindeWarnstufe = myGemeinde.warnstufe ?? "1"
            } catch {
                print("error")
            }
    }
    
    func sync() {
        loadingIndicator = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            rudi.fetchData()
            DispatchQueue.main.async {
                do {
                    try rudi.loadDataIntoCoreData()
                    loadingIndicator = false
                } catch {
                    print ("Core Data Error")
                }
            }
        }
    }
}

struct AmpelStartView_Previews: PreviewProvider {
    static var previews: some View {
        AmpelStartView()
    }
}
