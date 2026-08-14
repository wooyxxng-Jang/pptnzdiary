import Foundation
import SwiftData

@Model
final class Song {
    var id: UUID
    var title: String
    var album: String?

    init(id: UUID = UUID(), title: String, album: String? = nil) {
        self.id = id
        self.title = title
        self.album = album
    }
}
