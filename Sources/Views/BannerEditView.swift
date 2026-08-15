import SwiftUI
import SwiftData

struct BannerEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var selectedPreset: BannerColorPreset = .whiteOnBlack
    @State private var showDisplay = false

    var body: some View {
        NavigationStack {
            Form {
                Section("응원 구호") {
                    TextField("예: 장원아 사랑해", text: $text, axis: .vertical)
                        .lineLimit(1...3)
                }

                Section("색상") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(BannerColorPreset.allCases) { preset in
                                ColorSwatch(preset: preset, isSelected: preset == selectedPreset)
                                    .onTapGesture { selectedPreset = preset }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("전광판 만들기")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("전광판 띄우기") { saveAndShow() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .fullScreenCover(isPresented: $showDisplay) {
                BannerDisplayView(text: text, preset: selectedPreset)
            }
        }
    }

    private func saveAndShow() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let phrase = BannerPhrase(text: trimmed, colorKey: selectedPreset.rawValue)
        context.insert(phrase)
        showDisplay = true
    }
}

private struct ColorSwatch: View {
    let preset: BannerColorPreset
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(preset.backgroundColor)
                .overlay(
                    Circle()
                        .strokeBorder(preset.textColor, lineWidth: 2)
                        .padding(4)
                )
                .overlay(
                    Circle()
                        .strokeBorder(.primary, lineWidth: isSelected ? 2 : 0)
                        .padding(-3)
                )
                .frame(width: 44, height: 44)
            Text(preset.displayName)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    BannerEditView()
        .modelContainer(for: BannerPhrase.self, inMemory: true)
}
