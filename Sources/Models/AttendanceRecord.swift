import Foundation
import SwiftData

@Model
final class AttendanceRecord {
    var id: UUID
    var concert: Concert?
    var attended: Bool
    var seat: String?
    var companionNote: String?      // Phase 1: 텍스트로만 (Phase 2에서 팔로잉 태깅으로 대체)
    var howAttended: String?        // 예매 경로/이동 수단 메모

    // 평가
    var overallRating: Int          // 1~5
    var performanceRating: Int?     // 연주 실력
    var styleRatingJangwon: Int?    // 이장원 스타일 점수
    var styleRatingJaepyung: Int?   // 신재평 스타일 점수
    var priceNote: String?

    var favoriteMoments: [String]   // 프리셋(FavoriteMomentTag) rawValue 또는 커스텀 텍스트 혼용
    var memorableQuote: String?     // 기억에 남는 멘트
    var favoriteSong: Song?         // 가장 좋았던 곡
    var weatherSummary: String?     // 자동 조회된 날씨 요약
    var oneLineReview: String?      // 한줄평
    var createdAt: Date

    init(
        id: UUID = UUID(),
        concert: Concert? = nil,
        attended: Bool = true,
        seat: String? = nil,
        companionNote: String? = nil,
        howAttended: String? = nil,
        overallRating: Int = 0,
        performanceRating: Int? = nil,
        styleRatingJangwon: Int? = nil,
        styleRatingJaepyung: Int? = nil,
        priceNote: String? = nil,
        favoriteMoments: [String] = [],
        memorableQuote: String? = nil,
        favoriteSong: Song? = nil,
        weatherSummary: String? = nil,
        oneLineReview: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.concert = concert
        self.attended = attended
        self.seat = seat
        self.companionNote = companionNote
        self.howAttended = howAttended
        self.overallRating = overallRating
        self.performanceRating = performanceRating
        self.styleRatingJangwon = styleRatingJangwon
        self.styleRatingJaepyung = styleRatingJaepyung
        self.priceNote = priceNote
        self.favoriteMoments = favoriteMoments
        self.memorableQuote = memorableQuote
        self.favoriteSong = favoriteSong
        self.weatherSummary = weatherSummary
        self.oneLineReview = oneLineReview
        self.createdAt = createdAt
    }
}
