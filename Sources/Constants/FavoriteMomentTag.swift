import Foundation

/// 관람 기록 작성 시 "특히 좋았던 요소"를 고르는 프리셋 태그.
/// AttendanceRecord.favoriteMoments에는 이 rawValue 또는 사용자가 직접 입력한
/// 커스텀 텍스트가 함께 저장된다.
enum FavoriteMomentTag: String, CaseIterable, Identifiable {
    case encore = "앵콜"
    case newSong = "신곡"
    case talk = "멘트"
    case audienceInteraction = "관객 소통"
    case setlist = "셋리스트"
    case stageProduction = "무대 연출"
    case guest = "게스트"

    var id: String { rawValue }
}
