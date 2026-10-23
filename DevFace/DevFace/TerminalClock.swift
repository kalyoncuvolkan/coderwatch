import SwiftUI

/// The foreground of the face: a fake shell session that prints the time.
struct TerminalClock: View {
    let date: Date
    let theme: Theme
    let alwaysOn: Bool
    let battery: Float // 0...1, negative when unknown

    private static let commands = ["now", "date +%R", "uptime", "git log -1", "whoami", "make time"]
    private static let typingSpeed = 14.0   // chars per second
    private static let scrambleDuration = 0.7

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("EEE d MMM")
        return f
    }()

    private var calendar: Calendar { .current }

    /// Seconds into the current minute, with sub-second precision.
    private var secondOfMinute: Double {
        Double(calendar.component(.second, from: date))
            + date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            promptLine
            clockLine
            dateLine
            if !alwaysOn {
                epochLine
            }
            progressLine
            statusLine
        }
        .font(.system(size: 12, design: .monospaced))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }

    // MARK: Lines

    /// `➜ ~ git:(main) date +%R▌` – a new command is typed out every minute.
    private var promptLine: some View {
        let minute = Int(date.timeIntervalSince1970 / 60)
        let command = Self.commands[minute % Self.commands.count]
        let typed = alwaysOn
            ? command
            : String(command.prefix(Int(secondOfMinute * Self.typingSpeed)))
        let cursorOn = !alwaysOn && Int(date.timeIntervalSinceReferenceDate * 2) % 2 == 0

        return HStack(spacing: 0) {
            Text(verbatim: "➜ ").foregroundStyle(theme.keyword)
            Text(verbatim: "~ ").foregroundStyle(theme.number)
            Text(verbatim: "git:(").foregroundStyle(theme.secondary)
            Text(verbatim: "main").foregroundStyle(theme.string)
            Text(verbatim: ") ").foregroundStyle(theme.secondary)
            Text(verbatim: typed).foregroundStyle(.white)
            Text(verbatim: "▌").foregroundStyle(theme.primary).opacity(cursorOn ? 1 : 0)
        }
        .font(.system(size: 11, design: .monospaced))
    }

    /// Big HH:mm. When the minute flips, changed digits "decrypt" for a moment.
    private var clockLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: 1) {
            Text(verbatim: clockString)
                .font(.system(size: 50, weight: .semibold, design: .monospaced))
                .foregroundStyle(theme.primary)
                .shadow(color: alwaysOn ? .clear : theme.primary.opacity(0.55), radius: 6)
            if !alwaysOn {
                Text(verbatim: String(format: ":%02d", calendar.component(.second, from: date)))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundStyle(theme.secondary)
            }
        }
        .padding(.vertical, -2)
    }

    /// `let today = "Fri 23 Oct"`
    private var dateLine: some View {
        HStack(spacing: 0) {
            Text(verbatim: "let ").foregroundStyle(theme.keyword)
            Text(verbatim: "today = ").foregroundStyle(.white)
            Text(verbatim: "\"\(Self.dateFormatter.string(from: date))\"").foregroundStyle(theme.string)
        }
        .opacity(alwaysOn ? 0.6 : 1)
    }

    /// `epoch: 1792741627` – ticking Unix time.
    private var epochLine: some View {
        HStack(spacing: 0) {
            Text(verbatim: "epoch: ").foregroundStyle(theme.secondary)
            Text(verbatim: String(Int(date.timeIntervalSince1970))).foregroundStyle(theme.number)
        }
    }

    /// `day [██████░░░░] 58%` – how much of today has been "built".
    private var progressLine: some View {
        let fraction = date.timeIntervalSince(calendar.startOfDay(for: date)) / 86_400
        let blocks = 10
        let filled = min(blocks, Int(fraction * Double(blocks)))

        return HStack(spacing: 0) {
            Text(verbatim: "day [").foregroundStyle(theme.secondary)
            Text(verbatim: String(repeating: "█", count: filled)).foregroundStyle(theme.primary)
            Text(verbatim: String(repeating: "░", count: blocks - filled)).foregroundStyle(theme.secondary)
            Text(verbatim: "] ").foregroundStyle(theme.secondary)
            Text(verbatim: "\(Int(fraction * 100))%").foregroundStyle(theme.number)
        }
        .opacity(alwaysOn ? 0.6 : 1)
    }

    /// `bat: 87%  // W43`
    private var statusLine: some View {
        let batteryText = battery < 0 ? "--" : "\(Int((battery * 100).rounded()))%"
        let week = calendar.component(.weekOfYear, from: date)

        return HStack(spacing: 0) {
            Text(verbatim: "bat: ").foregroundStyle(theme.secondary)
            Text(verbatim: batteryText).foregroundStyle((0..<0.2).contains(battery) ? .red : theme.number)
            Text(verbatim: "  // W\(week)").foregroundStyle(theme.secondary)
        }
        .opacity(alwaysOn ? 0.6 : 1)
    }

    // MARK: Helpers

    private func hhmm(_ d: Date) -> String {
        let c = calendar.dateComponents([.hour, .minute], from: d)
        return String(format: "%02d:%02d", c.hour ?? 0, c.minute ?? 0)
    }

    private var clockString: String {
        let now = hhmm(date)
        let second = secondOfMinute
        guard !alwaysOn, second < Self.scrambleDuration else { return now }

        let previous = Array(hhmm(date.addingTimeInterval(-60)))
        let frame = Int(date.timeIntervalSinceReferenceDate * 20)
        return String(now.enumerated().map { index, char in
            // Each changed digit locks in a little after the one to its left.
            let settled = second > 0.25 + Double(index) * 0.1
            guard char != ":", char != previous[index], !settled else { return char }
            return Character(String(Int(noise(frame, index) * 10)))
        })
    }
}
