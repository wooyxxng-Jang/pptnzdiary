import Foundation
import SwiftData

@Model
final class BannerPhrase {
    var id: UUID
    var text: String
    var colorKey: String            // BannerColorPreset rawValue
    var createdAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        colorKey: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.text = text
        self.colorKey = colorKey
        self.createdAt = createdAt
    }
}
