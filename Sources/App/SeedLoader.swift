import Foundation
import SwiftData

enum SeedLoader {
    private struct SeedSetlistEntry: Decodable {
        let order: Int
        let songTitle: String
        let note: String?
        let isEncore: Bool
    }

    private struct SeedConcert: Decodable {
        let id: String
        let title: String
        let dateText: String
        let date: String
        let venue: String
        let tourType: String
        let note: String?
        let sourceNote: String?
        let setlist: [SeedSetlistEntry]
    }

    /// 앱 최초 실행 시(Concert가 0건일 때) SeedData.json을 읽어 SwiftData에 삽입한다.
    static func loadIfNeeded(context: ModelContext) {
        guard let existingCount = try? context.fetchCount(FetchDescriptor<Concert>()),
              existingCount == 0 else {
            return
        }

        guard let url = Bundle.main.url(forResource: "SeedData", withExtension: "json") else {
            print("SeedLoader: SeedData.json을 번들에서 찾을 수 없습니다.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let seedConcerts = try JSONDecoder().decode([SeedConcert].self, from: data)

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd"

            var songCache: [String: Song] = [:]

            let sentinelFutureDate = dateFormatter.date(from: "2099-12-31") ?? .distantFuture

            for seedConcert in seedConcerts {
                let date = dateFormatter.date(from: seedConcert.date) ?? sentinelFutureDate
                let concert = Concert(
                    id: UUID(uuidString: seedConcert.id) ?? UUID(),
                    title: seedConcert.title,
                    date: date,
                    dateText: seedConcert.dateText,
                    venue: seedConcert.venue,
                    tourType: seedConcert.tourType,
                    note: seedConcert.note,
                    sourceNote: seedConcert.sourceNote
                )
                context.insert(concert)

                for entry in seedConcert.setlist {
                    let song: Song
                    if let cached = songCache[entry.songTitle] {
                        song = cached
                    } else {
                        song = Song(title: entry.songTitle)
                        context.insert(song)
                        songCache[entry.songTitle] = song
                    }

                    let setlistEntry = SetlistEntry(
                        order: entry.order,
                        isEncore: entry.isEncore,
                        note: entry.note,
                        song: song,
                        concert: concert
                    )
                    context.insert(setlistEntry)
                }
            }

            try context.save()
        } catch {
            print("SeedLoader: 시드 데이터 로드 실패 - \(error)")
        }
    }
}
