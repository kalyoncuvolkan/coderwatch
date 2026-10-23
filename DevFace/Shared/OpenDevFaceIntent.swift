import AppIntents

/// Opens DevFace. Shared by the app and the widget extension so it can back
/// both the Siri/Shortcuts action and the Control Center / Action Button control.
struct OpenDevFaceIntent: AppIntent {
    static let title: LocalizedStringResource = "DevFace'i Aç"
    static let description = IntentDescription("Terminal temalı saat ekranını açar.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
