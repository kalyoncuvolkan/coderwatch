import AppIntents

/// Makes "Open DevFace" available to Siri, Shortcuts and the Smart Stack without
/// any setup. Watch-only apps don't show up in the Shortcuts "Open App" action.
struct DevFaceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenDevFaceIntent(),
            phrases: [
                "\(.applicationName) aç",
                "Open \(.applicationName)"
            ],
            shortTitle: "DevFace'i Aç",
            systemImageName: "apple.terminal"
        )
    }
}
