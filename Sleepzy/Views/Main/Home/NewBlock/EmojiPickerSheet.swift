import SwiftUI

// MARK: - EmojiPickerSheet
struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss

    private let categories: [(String, [String])] = [
        ("😊 Faces", ["😀","😎","🥱","😴","🤩","🥳","😤","🤯","🧠","👀","💪","🙏"]),
        ("🌙 Sleep", ["🌙","⭐️","🌟","💤","🛌","🌛","🌜","☁️","🌠","🌌","🌃","🔮"]),
        ("📱 Tech",  ["📱","💻","🖥","⌨️","🖱","📲","🔋","🔌","📡","🎮","🕹","⌚️"]),
        ("🏃 Activity", ["🏃","🧘","🏋️","🚴","🤸","🏊","🎯","🧗","🚶","💃","🤾","⛹️"]),
        ("🍎 Food",  ["🍎","🥑","🥦","🫐","🍊","🥝","🍇","🫚","🥗","🍵","☕️","🧃"]),
        ("🎯 Objects",["🎯","📚","🗒","✏️","🔑","🔒","🛡","⚡️","🔥","💡","🧩","🎲"]),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(categories, id: \.0) { category, emojis in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(category)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 4)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(emojis, id: \.self) { emoji in
                                    Button {
                                        selectedEmoji = emoji
                                        dismiss()
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 28))
                                            .frame(width: 52, height: 52)
                                            .background(
                                                selectedEmoji == emoji
                                                    ? AppTheme.accent.opacity(0.4)
                                                    : AppTheme.cardBackground
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedEmoji == emoji
                                                            ? AppTheme.accentBright
                                                            : Color.clear,
                                                        lineWidth: 1.5
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.vertical, 16)
            }
            .background(
                MyImage(source: .asset(.bgSounds))
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.accentBright)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }
}
