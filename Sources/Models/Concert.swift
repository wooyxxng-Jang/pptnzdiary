import Foundation
import SwiftData

@Model
final class Concert {
    var id: UUID
    var title: String
    var date: Date
    var dateText: String        // 원문 날짜 표기(범위/연월/미정 등 그대로 보존, 화면 표시용)
    var venue: String
    var venueLocation: String?
    var tourType: String
    var note: String?           // 공연 단위 비고 (출처 보강 설명 등, 원문 그대로 보존)
    var sourceNote: String?

    @Relationship(deleteRule: .cascade, inverse: \SetlistEntry.concert)
    var setlist: [SetlistEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \AttendanceRecord.concert)
    var attendanceRecords: [AttendanceRecord] = []

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        dateText: String,
        venue: String,
        venueLocation: String? = nil,
        tourType: String,
        note: String? = nil,
        sourceNote: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.dateText = dateText
        self.venue = venue
        self.venueLocation = venueLocation
        self.tourType = tourType
        self.note = note
        self.sourceNote = sourceNote
    }
}
