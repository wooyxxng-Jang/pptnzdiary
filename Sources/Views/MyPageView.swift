import SwiftUI

struct MyPageView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "내 기록",
                systemImage: "person.crop.circle",
                description: Text("관람 기록을 작성하면 여기에 표시됩니다.\n마일스톤 3에서 구현됩니다.")
            )
            .navigationTitle("내 기록")
        }
    }
}

#Preview {
    MyPageView()
}
