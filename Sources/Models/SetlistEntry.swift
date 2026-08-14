import Foundation
import SwiftData

@Model
final class SetlistEntry {
    var id: UUID
    var order: Int
    var isEncore: Bool
    var note: String?          // 원문 비고(원곡자/세션 표기 등, 원문 그대로 보존)
    var song: Song
    var concert: Concert?

    init(
        id: UUID = UUID(),
        order: Int,
        isEncore: Bool = false,
        note: String? = nil,
        song: Song,
        concert: Concert? = nil
    ) {
        self.id = id
        self.order = order
        self.isEncore = isEncore
        self.note = note
        self.song = song
        self.concert = concert
    }
}
