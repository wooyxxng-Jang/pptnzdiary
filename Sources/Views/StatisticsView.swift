import SwiftUI
import SwiftData
import Charts

private let unresolvedDateYear = 2099

struct StatisticsView: View {
    @Query private var concerts: [Concert]

    private var attendedConcerts: [Concert] {
        concerts.filter { $0.attendanceRecords.contains { $0.attended } }
    }

    private var overallRanking: [SongCount] {
        rankSongs(in: concerts)
    }

    private var attendedRanking: [SongCount] {
        rankSongs(in: attendedConcerts)
    }

    private var yearlyStats: [YearlyStat] {
        let calendar = Calendar(identifier: .gregorian)
        let totalByYear = Dictionary(grouping: concerts) { calendar.component(.year, from: $0.date) }
        let attendedByYear = Dictionary(grouping: attendedConcerts) { calendar.component(.year, from: $0.date) }

        let years = Set(totalByYear.keys).union(attendedByYear.keys)
            .filter { $0 != unresolvedDateYear }
            .sorted()

        return years.flatMap { year -> [YearlyStat] in
            [
                YearlyStat(year: year, category: "전체 공연", count: totalByYear[year]?.count ?? 0),
                YearlyStat(year: year, category: "내가 관람한 공연", count: attendedByYear[year]?.count ?? 0)
            ]
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("전체 곡별 연주 횟수 랭킹") {
                    if overallRanking.isEmpty {
                        Text("아직 셋리스트 데이터가 없어요.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(overallRanking.prefix(15).enumerated()), id: \.element.song.persistentModelID) { index, item in
                            RankingRow(rank: index + 1, title: item.song.title, count: item.count)
                        }
                    }
                }

                Section("내가 관람한 공연 곡별 통계") {
                    if attendedRanking.isEmpty {
                        Text("아직 관람 기록이 없어요.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(attendedRanking.prefix(15).enumerated()), id: \.element.song.persistentModelID) { index, item in
                            RankingRow(rank: index + 1, title: item.song.title, count: item.count)
                        }
                    }
                }

                Section("연도별 추이") {
                    if yearlyStats.isEmpty {
                        Text("아직 연도별 통계를 표시할 데이터가 없어요.")
                            .foregroundStyle(.secondary)
                    } else {
                        Chart(yearlyStats) { stat in
                            BarMark(
                                x: .value("연도", String(stat.year)),
                                y: .value("횟수", stat.count)
                            )
                            .foregroundStyle(by: .value("구분", stat.category))
                            .position(by: .value("구분", stat.category))
                        }
                        .frame(height: 220)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("통계")
        }
    }

    private func rankSongs(in concerts: [Concert]) -> [SongCount] {
        var counts: [PersistentIdentifier: Int] = [:]
        var songByID: [PersistentIdentifier: Song] = [:]

        for concert in concerts {
            for entry in concert.setlist {
                let id = entry.song.persistentModelID
                counts[id, default: 0] += 1
                songByID[id] = entry.song
            }
        }

        return counts.compactMap { id, count in
            guard let song = songByID[id] else { return nil }
            return SongCount(song: song, count: count)
        }
        .sorted { $0.count > $1.count }
    }
}

private struct SongCount {
    let song: Song
    let count: Int
}

private struct YearlyStat: Identifiable {
    let year: Int
    let category: String
    let count: Int

    var id: String { "\(year)-\(category)" }
}

private struct RankingRow: View {
    let rank: Int
    let title: String
    let count: Int

    var body: some View {
        HStack {
            Text("\(rank)")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .leading)
            Text(title)
            Spacer()
            Text("\(count)회")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    StatisticsView()
}
