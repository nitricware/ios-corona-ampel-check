//
//  RudiWidget.swift
//  RudiWidget
//
//  Created by Kurt Höblinger on 30.10.20.
//

import WidgetKit
import SwiftUI

/*
 This TimelineProvider is responsible for setting the update
 interval. By default, it sets an interval of 1 hour for the
 next 5 hours.
 */
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

/*
 This is the actual widget. It reuses some of the code of
 AmpelStartView.swift
 */

struct RudiWidgetEntryView : View {
    var entry: Provider.Entry
    let rudi = Rudi()
    @State private var myGemeinde: Region?
    
    @Environment(\.widgetFamily) var family
    
    @AppStorage("myGemeinde", store: UserDefaults(suiteName: "group.com.nitricware.Rudi")) var selectedGemeinde: String?

    @State private var trafficGreen: Color = .gray
    @State private var trafficYellow: Color = .gray
    @State private var trafficOrange: Color = .gray
    @State private var trafficRed: Color = .gray
    
    @State private var trafficSmall: Color = .gray
    
    var body: some View {
        VStack {
            Text(myGemeinde?.name ?? "Keine Gemeinde")
            HStack {
                if family == .systemSmall {
                    Circle()
                        .trafficLight(
                            fillColor: trafficSmall,
                            lineColor: Color.gray
                        )
                }
                if (family == .systemMedium || family == .systemLarge) {
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
            }
            if family == .systemLarge {
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
            }
        }
        .onAppear(perform: start)
    }
    
    func start() -> Void {
        do {
            myGemeinde = try rudi.getMyGemeinde(gkz: selectedGemeinde)
        } catch {
            print("Error occured while catching myGemeinde.")
        }
        
        trafficGreen = .gray
        trafficYellow = .gray
        trafficOrange = .gray
        trafficRed = .gray
        switch (myGemeinde?.warnstufe ?? "0") {
        case "1":
            trafficSmall = .green
            trafficGreen = .green
        case "2":
            trafficSmall = .yellow
            trafficYellow = .yellow
        case "3":
            trafficSmall = .orange
            trafficOrange = .orange
        case "4":
            trafficSmall = .red
            trafficRed = .red
        default:
            trafficSmall = .gray
            trafficGreen = .gray
        }
    }
}

/*
 The section below holds the necessary code for the
 add widget screen.
 */
@main
struct RudiWidget: Widget {
    let kind: String = "RudiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RudiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ampel")
        .description("Mit dem Widget siehst du die aktuelle Ampelfarbe deiner eingestellten Gemeinde.")
    }
}

// MARK: Preview
struct RudiWidget_Previews: PreviewProvider {
    static var previews: some View {
        RudiWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
