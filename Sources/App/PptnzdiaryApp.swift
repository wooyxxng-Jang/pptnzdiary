import SwiftUI
import SwiftData

@main
struct PptnzdiaryApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Concert.self,
            Song.self,
            SetlistEntry.self,
            AttendanceRecord.self,
            BannerPhrase.self
        ])
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    SeedLoader.loadIfNeeded(context: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
