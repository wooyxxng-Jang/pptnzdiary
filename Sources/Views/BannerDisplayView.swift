import SwiftUI

/// 공연장에서 응원 구호를 화면 가득 크게 띄우는 전체화면 뷰.
/// 앱은 세로 고정이지만, 실제로는 핸드폰을 가로로 들고 보는 용도이므로
/// 콘텐츠 자체를 90도 회전시켜 가로로 읽히게 한다.
/// 탭하면 닫히고, 표시되는 동안 화면 자동 잠금을 막는다.
struct BannerDisplayView: View {
    let text: String
    let preset: BannerColorPreset

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            preset.backgroundColor
                .ignoresSafeArea()
                .overlay {
                    Text(text)
                        .font(.system(size: 600, weight: .black))
                        .minimumScaleFactor(0.01)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(preset.textColor)
                        .padding(24)
                        .frame(width: geo.size.height, height: geo.size.width)
                        .rotationEffect(.degrees(90))
                        .frame(width: geo.size.width, height: geo.size.height)
                }
        }
        .ignoresSafeArea()
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
