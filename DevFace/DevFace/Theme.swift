import SwiftUI

/// Colour palette for the face. Turn the Digital Crown to cycle through them.
struct Theme: Identifiable, Equatable {
    let id: String
    let primary: Color    // big clock digits
    let secondary: Color  // comments, dimmed text
    let keyword: Color    // syntax: keywords / prompt
    let string: Color     // syntax: strings
    let number: Color     // syntax: numbers
    let rain: Color       // background code rain

    static let all: [Theme] = [.terminal, .ultra, .dracula, .night]

    /// Classic green-on-black terminal.
    static let terminal = Theme(
        id: "terminal",
        primary: Color(hex: 0x4DFF73),
        secondary: Color(hex: 0x5C6B61),
        keyword: Color(hex: 0x4DFF73),
        string: Color(hex: 0xE6DB74),
        number: Color(hex: 0x66D9EF),
        rain: Color(hex: 0x1FD15A)
    )

    /// Apple Watch Ultra "International Orange".
    static let ultra = Theme(
        id: "ultra",
        primary: Color(hex: 0xFF6A13),
        secondary: Color(hex: 0x6B5B52),
        keyword: Color(hex: 0xFF6A13),
        string: Color(hex: 0xFFC799),
        number: Color(hex: 0xFFFFFF),
        rain: Color(hex: 0xFF6A13)
    )

    /// Dracula editor theme.
    static let dracula = Theme(
        id: "dracula",
        primary: Color(hex: 0xBD93F9),
        secondary: Color(hex: 0x6272A4),
        keyword: Color(hex: 0xFF79C6),
        string: Color(hex: 0xF1FA8C),
        number: Color(hex: 0x50FA7B),
        rain: Color(hex: 0xBD93F9)
    )

    /// All red, matches the Ultra's Night Mode.
    static let night = Theme(
        id: "night",
        primary: Color(hex: 0xFF2A1F),
        secondary: Color(hex: 0x6E1410),
        keyword: Color(hex: 0xFF2A1F),
        string: Color(hex: 0xC41F17),
        number: Color(hex: 0xFF2A1F),
        rain: Color(hex: 0xA3150F)
    )
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

/// Cheap deterministic pseudo-random number in 0..<1, so animations are
/// pure functions of time and need no mutable state.
func noise(_ a: Int, _ b: Int = 0) -> Double {
    var x = UInt64(bitPattern: Int64((a &* 73_856_093) ^ (b &* 19_349_663)))
    x ^= x >> 33
    x &*= 0xFF51_AFD7_ED55_8CCD
    x ^= x >> 33
    x &*= 0xC4CE_B9FE_1A85_EC53
    x ^= x >> 33
    return Double(x % 10_000) / 10_000
}
