import SwiftUI

/// 전광판(응원 구호) 배경/글자 색상 프리셋. 공연장에서 멀리서도 잘 보이도록
/// 대비가 큰 조합 위주로 구성.
enum BannerColorPreset: String, CaseIterable, Identifiable {
    case whiteOnBlack = "화이트 온 블랙"
    case yellowOnBlack = "옐로우 온 블랙"
    case pinkOnBlack = "핑크 온 블랙"
    case skyBlueOnBlack = "스카이블루 온 블랙"
    case blackOnWhite = "블랙 온 화이트"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .whiteOnBlack, .yellowOnBlack, .pinkOnBlack, .skyBlueOnBlack:
            return .black
        case .blackOnWhite:
            return .white
        }
    }

    var textColor: Color {
        switch self {
        case .whiteOnBlack:
            return .white
        case .yellowOnBlack:
            return .yellow
        case .pinkOnBlack:
            return .pink
        case .skyBlueOnBlack:
            return Color(red: 0.4, green: 0.75, blue: 1.0)
        case .blackOnWhite:
            return .black
        }
    }
}
