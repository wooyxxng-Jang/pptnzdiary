import SwiftUI
import SwiftData

enum AttendanceFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case attended = "관람함"
    case notAttended = "관람 안 함"

    var id: String { rawValue }
}

enum TourTypeFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case solo = "단독 공연"
    case external = "외부 공연"

    var id: String { rawValue }
}

struct ConcertArchiveView: View {
    @Query(sort: \Concert.date, order: .reverse) private var concerts: [Concert]

    @State private var attendanceFilter: AttendanceFilter = .all
    @State private var tourTypeFilter: TourTypeFilter = .all
    @State private var isShowingAddConcert = false

    private var filteredConcerts: [Concert] {
        concerts.filter { concert in
            let attendanceMatches: Bool
            switch attendanceFilter {
            case .all:
                attendanceMatches = true
            case .attended:
                attendanceMatches = concert.attendanceRecords.contains { $0.attended }
            case .notAttended:
                attendanceMatches = !concert.attendanceRecords.contains { $0.attended }
            }

            let tourTypeMatches: Bool
            switch tourTypeFilter {
            case .all:
                tourTypeMatches = true
            case .solo:
                tourTypeMatches = concert.tourType == "단독 공연"
            case .external:
                tourTypeMatches = concert.tourType == "외부 공연"
            }

            return attendanceMatches && tourTypeMatches
        }
    }

    private var groupedByYear: [(year: Int, concerts: [Concert])] {
        let calendar = Calendar(identifier: .gregorian)
        let groups = Dictionary(grouping: filteredConcerts) { calendar.component(.year, from: $0.date) }
        return groups
            .sorted { $0.key > $1.key }
            .map { (year: $0.key, concerts: $0.value) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if groupedByYear.isEmpty {
                    ContentUnavailableView(
                        "공연 아카이브",
                        systemImage: "music.mic",
                        description: Text(concerts.isEmpty ? "아직 등록된 공연이 없습니다." : "조건에 맞는 공연이 없습니다.")
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("관람 여부", selection: $attendanceFilter) {
                            ForEach(AttendanceFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        Picker("공연 종류", selection: $tourTypeFilter) {
                            ForEach(TourTypeFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                    } label: {
                        Label("필터", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddConcert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddConcert) {
                NavigationStack {
                    AddConcertView()
                }
            }
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
