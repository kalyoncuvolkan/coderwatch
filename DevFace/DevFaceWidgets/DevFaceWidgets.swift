import AppIntents
import SwiftUI
import WidgetKit

// Complications for the built-in faces (e.g. Modular Ultra) and the Smart Stack.
// Tapping any of them opens the DevFace app.

struct DayEntry: TimelineEntry {
    let date: Date

    var dayFraction: Double {
        date.timeIntervalSince(Calendar.current.startOfDay(for: date)) / 86_400
    }
}

struct DayProvider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry { DayEntry(date: .now) }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(DayEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        // One entry every 5 minutes for the next 4 hours keeps the progress fresh.
        let start = Date.now
        let entries = (0..<48).map { DayEntry(date: start.addingTimeInterval(Double($0) * 300)) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct DevFaceComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DayEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: entry.dayFraction) {
                Text(verbatim: "day")
            } currentValueLabel: {
                Text(verbatim: "</>")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .gaugeStyle(.accessoryCircular)

        case .accessoryCorner:
            Text(verbatim: "</>")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .widgetLabel {
                    Gauge(value: entry.dayFraction) { Text(verbatim: "day") }
                }

        case .accessoryInline:
            Text(verbatim: "➜ day \(Int(entry.dayFraction * 100))% built")

        default: // .accessoryRectangular
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: "➜ ~ git:(main) now")
                    .foregroundStyle(.orange)
                Text(entry.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .widgetAccentable()
                Gauge(value: entry.dayFraction) {
                    Text(verbatim: "day")
                }
                .gaugeStyle(.accessoryLinearCapacity)
            }
            .font(.system(size: 13, design: .monospaced))
        }
    }
}

@main
struct DevFaceWidgetBundle: WidgetBundle {
    var body: some Widget {
        DevFaceWidget()
        DevFaceControl()
    }
}

struct DevFaceWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DevFaceComplication", provider: DayProvider()) { entry in
            DevFaceComplicationView(entry: entry)
                .containerBackground(for: .widget) { Color.black }
        }
        .configurationDisplayName("DevFace")
        .description("Terminal-style day progress. Tap to open DevFace.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular])
    }
}

/// One-tap "open DevFace" control for Control Center and the Ultra's Action Button.
struct DevFaceControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "DevFaceControl") {
            ControlWidgetButton(action: OpenDevFaceIntent()) {
                Label("DevFace", systemImage: "apple.terminal")
            }
        }
        .displayName("DevFace")
        .description("DevFace'i açar.")
    }
}
