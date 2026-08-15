import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ConcertArchiveView()
                .tabItem {
                    Label("공연 아카이브", systemImage: "music.mic")
                }

            MyPageView()
                .tabItem {
                    Label("내 기록", systemImage: "person.crop.circle")
                }

            StatisticsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }

            ToolsView()
                .tabItem {
                    Label("도구", systemImage: "wrench.and.screwdriver")
                }
        }
    }
}

#Preview {
    RootTabView()
}
