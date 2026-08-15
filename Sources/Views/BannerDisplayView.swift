import SwiftUI

/// 공연장에서 응원 구호를 화면 가득 크게 띄우는 전체화면 뷰.
/// 탭하면 닫히고, 표시되는 동안 화면 자동 잠금을 막는다.
struct BannerDisplayView: View {
    let text: String
    let preset: BannerColorPreset

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        preset.backgroundColor
            .ignoresSafeArea()
            .overlay {
                Text(text)
                    .font(.system(size: 400, weight: .heavy))
                    .minimumScaleFactor(0.01)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(preset.textColor)
                    .padding(24)
            }
            .statusBarHidden(true)
            .contentShape(Rectangle())
            .onTapGesture { dismiss() }
            .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }
}

#Preview {
    BannerDisplayView(text: "장원아 사랑해", preset: .yellowOnBlack)
}
