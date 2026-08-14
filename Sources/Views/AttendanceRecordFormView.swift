import SwiftUI
import SwiftData
import PhotosUI

struct AttendanceRecordFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let concert: Concert
    private let existingRecord: AttendanceRecord?

    @State private var attended: Bool
    @State private var seat: String
    @State private var howAttended: String
    @State private var companionNote: String
    @State private var overallRating: Int
    @State private var performanceRating: Int
    @State private var styleRatingJangwon: Int
    @State private var styleRatingJaepyung: Int
    @State private var priceNote: String
    @State private var favoriteMoments: [String]
    @State private var customMomentText: String = ""
    @State private var memorableQuote: String
    @State private var favoriteSong: Song?
    @State private var weatherSummary: String
    @State private var oneLineReview: String
    @State private var isLoadingWeather = false
    @State private var weatherErrorMessage: String?
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(concert: Concert) {
        self.concert = concert
        let record = concert.attendanceRecords.first
        self.existingRecord = record

        _attended = State(initialValue: record?.attended ?? true)
        _seat = State(initialValue: record?.seat ?? "")
        _howAttended = State(initialValue: record?.howAttended ?? "")
        _companionNote = State(initialValue: record?.companionNote ?? "")
        _overallRating = State(initialValue: record?.overallRating ?? 0)
        _performanceRating = State(initialValue: record?.performanceRating ?? 0)
        _styleRatingJangwon = State(initialValue: record?.styleRatingJangwon ?? 0)
        _styleRatingJaepyung = State(initialValue: record?.styleRatingJaepyung ?? 0)
        _priceNote = State(initialValue: record?.priceNote ?? "")
        _favoriteMoments = State(initialValue: record?.favoriteMoments ?? [])
        _memorableQuote = State(initialValue: record?.memorableQuote ?? "")
        _favoriteSong = State(initialValue: record?.favoriteSong)
        _weatherSummary = State(initialValue: record?.weatherSummary ?? "")
        _oneLineReview = State(initialValue: record?.oneLineReview ?? "")
        _photoData = State(initialValue: record?.photoData)
    }

    private var setlistSongs: [Song] {
        var seen = Set<PersistentIdentifier>()
        var songs: [Song] = []
        for entry in concert.setlist.sorted(by: { $0.order < $1.order }) {
            if seen.insert(entry.song.persistentModelID).inserted {
                songs.append(entry.song)
            }
        }
        return songs
    }

    private var customMoments: [String] {
        let presetValues = Set(FavoriteMomentTag.allCases.map(\.rawValue))
        return favoriteMoments.filter { !presetValues.contains($0) }
    }

    var body: some View {
        Form {
            Section {
                Toggle("공연에 다녀왔어요", isOn: $attended)
            }

            Section("대표 사진") {
                if let photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button("사진 삭제", role: .destructive) {
                        self.photoData = nil
                        selectedPhotoItem = nil
                    }
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text(photoData == nil ? "사진 선택" : "사진 변경")
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task { await loadPhoto(from: newItem) }
                }
            }

            Section("관람 정보") {
                TextField("좌석", text: $seat)
                TextField("어떻게 다녀왔는지 (예매/이동 수단)", text: $howAttended)
                TextField("동행 메모", text: $companionNote)
            }

            Section("평가") {
                StarRatingRow(title: "총평", rating: $overallRating)
                StarRatingRow(title: "연주력", rating: $performanceRating)
                StarRatingRow(title: "이장원 스타일", rating: $styleRatingJangwon)
                StarRatingRow(title: "신재평 스타일", rating: $styleRatingJaepyung)
                TextField("가격 메모", text: $priceNote)
            }

            Section("특히 좋았던 요소") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(FavoriteMomentTag.allCases) { tag in
                        chip(label: tag.rawValue, isSelected: favoriteMoments.contains(tag.rawValue)) {
                            toggleMoment(tag.rawValue)
                        }
                    }
                }

                if !customMoments.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(customMoments, id: \.self) { moment in
                            removableChip(label: moment) {
                                favoriteMoments.removeAll { $0 == moment }
                            }
                        }
                    }
                }

                HStack {
                    TextField("직접 입력", text: $customMomentText)
                    Button("추가") {
                        addCustomMoment()
                    }
                    .disabled(customMomentText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section("기억에 남는 순간") {
                TextField("기억에 남는 멘트", text: $memorableQuote, axis: .vertical)

                if !setlistSongs.isEmpty {
                    Picker("가장 좋았던 곡", selection: $favoriteSong) {
                        Text("선택 안 함").tag(Song?.none)
                        ForEach(setlistSongs) { song in
                            Text(song.title).tag(Song?.some(song))
                        }
                    }
                }
            }

            Section("날씨") {
                TextField("날씨 메모 (예: 맑음, 15도)", text: $weatherSummary)

                if WeatherService.isDateSupported(concert.date) {
                    Button {
                        Task { await fetchWeather() }
                    } label: {
                        HStack {
                            Text("날씨 자동 조회")
                            if isLoadingWeather {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isLoadingWeather)
                } else {
                    Text("공연 날짜가 확정되지 않아 자동 조회할 수 없어요.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let weatherErrorMessage {
                    Text(weatherErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section("한줄평") {
                TextField("한줄평", text: $oneLineReview, axis: .vertical)
            }
        }
        .navigationTitle(existingRecord == nil ? "관람 기록 작성" : "관람 기록 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") { save() }
            }
        }
    }

    private func fetchWeather() async {
        isLoadingWeather = true
        weatherErrorMessage = nil
        do {
            weatherSummary = try await WeatherService.fetchWeatherSummary(date: concert.date, venue: concert.venue)
        } catch {
            weatherErrorMessage = error.localizedDescription
        }
        isLoadingWeather = false
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data),
              let compressed = uiImage.jpegData(compressionQuality: 0.6) else {
            return
        }
        photoData = compressed
    }

    private func toggleMoment(_ value: String) {
        if let index = favoriteMoments.firstIndex(of: value) {
            favoriteMoments.remove(at: index)
        } else {
            favoriteMoments.append(value)
        }
    }

    private func addCustomMoment() {
        let trimmed = customMomentText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !favoriteMoments.contains(trimmed) else { return }
        favoriteMoments.append(trimmed)
        customMomentText = ""
    }

    private func chip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func removableChip(label: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(label)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }

    private func save() {
        let normalizedSeat = seat.isEmpty ? nil : seat
        let normalizedHowAttended = howAttended.isEmpty ? nil : howAttended
        let normalizedCompanionNote = companionNote.isEmpty ? nil : companionNote
        let normalizedPriceNote = priceNote.isEmpty ? nil : priceNote
        let normalizedMemorableQuote = memorableQuote.isEmpty ? nil : memorableQuote
        let normalizedWeatherSummary = weatherSummary.isEmpty ? nil : weatherSummary
        let normalizedOneLineReview = oneLineReview.isEmpty ? nil : oneLineReview

        if let record = existingRecord {
            record.attended = attended
            record.seat = normalizedSeat
            record.howAttended = normalizedHowAttended
            record.companionNote = normalizedCompanionNote
            record.overallRating = overallRating
            record.performanceRating = performanceRating == 0 ? nil : performanceRating
            record.styleRatingJangwon = styleRatingJangwon == 0 ? nil : styleRatingJangwon
            record.styleRatingJaepyung = styleRatingJaepyung == 0 ? nil : styleRatingJaepyung
            record.priceNote = normalizedPriceNote
            record.favoriteMoments = favoriteMoments
            record.memorableQuote = normalizedMemorableQuote
            record.favoriteSong = favoriteSong
            record.weatherSummary = normalizedWeatherSummary
            record.oneLineReview = normalizedOneLineReview
            record.photoData = photoData
        } else {
            let record = AttendanceRecord(
                concert: concert,
                attended: attended,
                seat: normalizedSeat,
                companionNote: normalizedCompanionNote,
                howAttended: normalizedHowAttended,
                overallRating: overallRating,
                performanceRating: performanceRating == 0 ? nil : performanceRating,
                styleRatingJangwon: styleRatingJangwon == 0 ? nil : styleRatingJangwon,
                styleRatingJaepyung: styleRatingJaepyung == 0 ? nil : styleRatingJaepyung,
                priceNote: normalizedPriceNote,
                favoriteMoments: favoriteMoments,
                memorableQuote: normalizedMemorableQuote,
                favoriteSong: favoriteSong,
                weatherSummary: normalizedWeatherSummary,
                oneLineReview: normalizedOneLineReview,
                photoData: photoData
            )
            context.insert(record)
            concert.attendanceRecords.append(record)
        }

        try? context.save()
        dismiss()
    }
}

private struct StarRatingRow: View {
    let title: String
    @Binding var rating: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(star <= rating ? .yellow : .gray)
                        .onTapGesture {
                            rating = (rating == star) ? 0 : star
                        }
                }
            }
        }
    }
}
