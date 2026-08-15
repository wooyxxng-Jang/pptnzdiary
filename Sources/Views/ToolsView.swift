import SwiftUI
import SwiftData

struct ToolsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BannerPhrase.createdAt, order: .reverse) private var phrases: [BannerPhrase]

    @State private var showEditor = false
    @State private var selectedPhrase: BannerPhrase?

    var body: some View {
        NavigationStack {
            Group {
                if phrases.isEmpty {
                    ContentUnavailableView(
                        "전광판 만들기",
                        systemImage: "rectangle.inset.filled",
                        description: Text("응원 구호를 큰 글씨로 화면에 띄워보세요.")
                    )
                } else {
                    List {
                        ForEach(phrases) { phrase in
                            Button {
                                selectedPhrase = phrase
                            } label: {
                                PhraseRow(phrase: phrase)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deletePhrases)
                    }
                }
            }
            .navigationTitle("도구")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showEditor = true
                    } label: {
                        Label("새 전광판 만들기", systemImage: "plus")
                    }
                }
                if phrases.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Button("새 전광판 만들기") { showEditor = true }
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                BannerEditView()
            }
            .fullScreenCover(item: $selectedPhrase) { phrase in
                BannerDisplayView(
                    text: phrase.text,
                    preset: BannerColorPreset(rawValue: phrase.colorKey) ?? .whiteOnBlack
                )
            }
        }
    }

    private func deletePhrases(at offsets: IndexSet) {
        for index in offsets {
            context.delete(phrases[index])
        }
    }
}

private struct PhraseRow: View {
    let phrase: BannerPhrase

    private var preset: BannerColorPreset {
        BannerColorPreset(rawValue: phrase.colorKey) ?? .whiteOnBlack
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(preset.backgroundColor)
                .overlay(Circle().strokeBorder(preset.textColor, lineWidth: 2).padding(3))
                .frame(width: 28, height: 28)

            Text(phrase.text)
                .lineLimit(1)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ToolsView()
        .modelContainer(for: BannerPhrase.self, inMemory: true)
}
