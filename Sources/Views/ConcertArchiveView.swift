import SwiftUI
import SwiftData

struct ConcertArchiveView: View {
    @Query(sort: \Concert.date, order: .reverse) private var concerts: [Concert]

    private var groupedByYear: [(year: Int, concerts: [Concert])] {
        let calendar = Calendar(identifier: .gregorian)
        let groups = Dictionary(grouping: concerts) { calendar.component(.year, from: $0.date) }
        return groups
            .sorted { $0.key > $1.key }
            .map { (year: $0.key, concerts: $0.value) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if concerts.isEmpty {
                    ContentUnavailableView(
                        "공연 아카이브",
                        systemImage: "music.mic",
                        description: Text("아직 등록된 공연이 없습니다.")
                    )
                } else {
                    List {
                        ForEach(groupedByYear, id: \.year) { group in
                            Section(yearTitle(for: group.year)) {
                                ForEach(group.concerts) { concert in
                                    NavigationLink(value: concert) {
                                        ConcertRow(concert: concert)
                                    }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Concert.self) { concert in
                        ConcertDetailView(concert: concert)
                    }
                }
            }
            .navigationTitle("공연 아카이브")
        }
    }

    private func yearTitle(for year: Int) -> String {
        year >= 2099 ? "날짜 미정" : "\(year)년"
    }
}

private struct ConcertRow: View {
    let concert: Concert

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(concert.title)
                .font(.headline)

            HStack(spacing: 6) {
                Text(concert.dateText)
                if !concert.venue.isEmpty {
                    Text("· \(concert.venue)")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if concert.tourType == "단독 공연" {
                Text(concert.tourType)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ConcertArchiveView()
}
