import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "도구",
                systemImage: "wrench.and.screwdriver",
                description: Text("전광판 만들기 기능은 마일스톤 6에서 구현됩니다.")
            )
            .navigationTitle("도구")
        }
    }
}

#Preview {
    ToolsView()
}
