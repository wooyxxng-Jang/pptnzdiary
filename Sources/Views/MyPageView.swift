import SwiftUI
import SwiftData

struct MyPageView: View {
    @Query(sort: \AttendanceRecord.createdAt, order: .reverse) private var records: [AttendanceRecord]

    private var averageRating: Double {
        guard !records.isEmpty else { return 0 }
        let sum = records.reduce(0) { $0 + $1.overallRating }
        return Double(sum) / Double(records.count)
    }

    private var mostAttendedSongTitle: String? {
        var counts: [String: Int] = [:]
        for record in records where record.attended {
            guard let concert = record.concert else { continue }
            for entry in concert.setlist {
                counts[entry.song.title, default: 0] += 1
            }
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "내 기록",
                        systemImage: "person.crop.circle",
                        description: Text("관람 기록을 작성하면 여기에 표시됩니다.")
                    )
                } else {
                    List {
                        Section("요약") {
                            SummaryRow(label: "총 관람 횟수", value: "\(records.count)회")
                            SummaryRow(label: "평균 별점", value: String(format: "%.1f점", averageRating))
                            SummaryRow(label: "최다 관람곡", value: mostAttendedSongTitle ?? "-")
                        }

                        Section("내 기록") {
                            ForEach(records) { record in
                                if let concert = record.concert {
                                    NavigationLink {
                                        AttendanceRecordFormView(concert: concert)
                                    } label: {
                                        RecordRow(record: record, concert: concert)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("내 기록")
        }
    }
}

private struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

private struct RecordRow: View {
    let record: AttendanceRecord
    let concert: Concert

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(concert.title)
                .font(.headline)

            Text(concert.dateText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= record.overallRating ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(star <= record.overallRating ? .yellow : .gray)
                }
            }

            if let review = record.oneLineReview, !review.isEmpty {
                Text(review)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MyPageView()
}
