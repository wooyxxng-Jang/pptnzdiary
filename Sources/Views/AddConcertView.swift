import SwiftUI
import SwiftData

struct AddConcertView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var venue: String = ""
    @State private var tourType: String = "단독 공연"

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            Section("공연 정보") {
                TextField("공연 제목", text: $title)
                DatePicker("날짜", selection: $date, displayedComponents: .date)
                TextField("공연장", text: $venue)
                Picker("공연 종류", selection: $tourType) {
                    Text("단독 공연").tag("단독 공연")
                    Text("외부 공연").tag("외부 공연")
                }
            }
        }
        .navigationTitle("공연 추가")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") { save() }
                    .disabled(isSaveDisabled)
            }
        }
    }

    private func save() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy.MM.dd"

        let concert = Concert(
            title: title.trimmingCharacters(in: .whitespaces),
            date: date,
            dateText: dateFormatter.string(from: date),
            venue: venue.trimmingCharacters(in: .whitespaces),
            tourType: tourType,
            sourceNote: "직접 추가"
        )
        context.insert(concert)
        try? context.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddConcertView()
    }
}
