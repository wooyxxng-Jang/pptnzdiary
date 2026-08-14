import SwiftUI

struct ConcertDetailView: View {
    let concert: Concert

    private var sortedSetlist: [SetlistEntry] {
        concert.setlist.sorted { $0.order < $1.order }
    }

    private var mainSetlist: [SetlistEntry] {
        sortedSetlist.filter { !$0.isEncore }
    }

    private var encoreSetlist: [SetlistEntry] {
        sortedSetlist.filter { $0.isEncore }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(concert.title)
                        .font(.title2.bold())

                    Label(concert.dateText, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if !concert.venue.isEmpty {
                        Label(concert.venue, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if concert.tourType == "단독 공연" {
                        Text(concert.tourType)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }

                    if let note = concert.note, !note.isEmpty {
                        Text(note)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                NavigationLink {
                    AttendanceRecordFormView(concert: concert)
                } label: {
                    Label(
                        concert.attendanceRecords.isEmpty ? "관람 기록 작성" : "관람 기록 보기/수정",
                        systemImage: "square.and.pencil"
                    )
                }
            }

            if sortedSetlist.isEmpty {
                Section("셋리스트") {
                    Text("셋리스트 정보가 없습니다.")
                        .foregroundStyle(.secondary)
                }
            } else {
                if !mainSetlist.isEmpty {
                    Section("셋리스트") {
                        ForEach(mainSetlist) { entry in
                            SetlistRow(entry: entry)
                        }
                    }
                }

                if !encoreSetlist.isEmpty {
                    Section("앵콜") {
                        ForEach(encoreSetlist) { entry in
                            SetlistRow(entry: entry)
                        }
                    }
                }
            }

            Section {
                Text("공연 정보 출처: 나무위키 (CC BY-NC-SA 2.0 KR)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(concert.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SetlistRow: View {
    let entry: SetlistEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(entry.order). \(entry.song.title)")
            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
