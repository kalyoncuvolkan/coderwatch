import SwiftUI
import WatchKit

struct FaceView: View {
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @AppStorage("themeIndex") private var themeIndex = 0
    @AppStorage("rainEnabled") private var rainEnabled = true
    @State private var crown = 0.0

    private var theme: Theme { Theme.all[themeIndex % Theme.all.count] }

    var body: some View {
        Group {
            // Full frame rate while awake; once a minute in Always-On.
            if isLuminanceReduced {
                TimelineView(.everyMinute) { face(at: $0.date) }
            } else {
                TimelineView(.animation(minimumInterval: 1 / 20)) { face(at: $0.date) }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            rainEnabled.toggle()
            WKInterfaceDevice.current().play(.click)
        }
        // Digital Crown cycles through the themes.
        .focusable()
        .digitalCrownRotation(
            $crown,
            from: 0,
            through: Double(Theme.all.count - 1),
            by: 1,
            sensitivity: .low,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crown) { _, value in
            themeIndex = Int(value.rounded()) % Theme.all.count
        }
        .onAppear {
            crown = Double(themeIndex)
            WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        }
        .toolbar(.hidden, for: .navigationBar)
        .persistentSystemOverlays(.hidden)
    }

    private func face(at date: Date) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if rainEnabled && !isLuminanceReduced {
                CodeRainView(date: date, color: theme.rain)
                    .opacity(0.28)
                    .ignoresSafeArea()
            }

            TerminalClock(
                date: date,
                theme: theme,
                alwaysOn: isLuminanceReduced,
                battery: WKInterfaceDevice.current().batteryLevel
            )
        }
    }
}

#Preview {
    FaceView()
}
