//
//  Rudi_Widget.swift
//  Rudi Widget
//
//  Created by Kurt Höblinger on 27.09.20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct Rudi_WidgetEntryView : View {
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
                        .fill(trafficSmall)
                        .frame(width: 50, height: 50)
                        /*.overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.red, lineWidth: 4)
                        )*/
                }
                if (family == .systemMedium || family == .systemLarge) {
                    Circle()
                        .fill(trafficRed)
                        .frame(width: 50, height: 50)
                        /*.overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.red, lineWidth: 4)
                        )*/
                    Circle()
                        .fill(trafficOrange)
                        .frame(width: 50, height: 50)
                        /*.overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.orange, lineWidth: 4)
                        )*/
                    Circle()
                        .fill(trafficYellow)
                        .frame(width: 50, height: 50)
                        /*.overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.yellow, lineWidth: 4)
                        )*/
                    Circle()
                        .fill(trafficGreen)
                        .frame(width: 50, height: 50)
                        /*.overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.green, lineWidth: 4)
                        )*/
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
            print("oops")
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

@main
struct Rudi_Widget: Widget {
    let kind: String = "Rudi_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Rudi_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ampel")
        .description("Mit dem Widget siehst du die aktuelle Ampelfarbe deiner eingestellten Gemeinde.")
    }
}

struct Rudi_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Rudi_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
