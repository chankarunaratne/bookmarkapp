import SwiftUI
import SwiftData

struct BookPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    
    @State private var isShowingNewBookSheet: Bool = false
    @State private var newTitle: String = ""
    @State private var newAuthor: String = ""
    
    var onPicked: (Book) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if books.isEmpty {
                        Text("No books yet. Tap the plus to add your first book.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 24)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(books) { book in
                            BookPickerRow(book: book) {
                                onPicked(book)
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        newTitle = ""
                        newAuthor = ""
                        isShowingNewBookSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .accessibilityLabel("Add Book")
                }
            }
            // Sheet close button is provided by the system; no custom close button here.
            .sheet(isPresented: $isShowingNewBookSheet) {
                NewBookSheet(title: $newTitle, author: $newAuthor) { title, author in
                    let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedTitle.isEmpty else { return }
                    let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let book = Book(
                        title: trimmedTitle,
                        author: trimmedAuthor.isEmpty ? nil : trimmedAuthor
                    )
                    modelContext.insert(book)
                    
                    // Immediately treat the newly created book as selected.
                    onPicked(book)
                }
            }
        }
    }
}

struct BookPickerRow: View {
    let book: Book
    var onSelect: () -> Void
    
    private var subtitle: String {
        if book.quotesCount > 0 {
            return "\(book.quotesCount) highlight\(book.quotesCount == 1 ? "" : "s")"
        } else {
            return "No highlights yet"
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            BookThumbnailView(book: book)
                .frame(width: 54, height: 78)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 8)
            
            Button(action: onSelect) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add quote to \(book.title)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}

/// Simple sheet stacked on top of the picker that only asks for a book title.
struct NewBookSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var title: String
    @Binding var author: String
    var onCreate: (String, String) -> Void
    
    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Book title", text: $title)
                    TextField("Author (optional)", text: $author)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("New Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onCreate(title, author)
                        dismiss()
                    }
                    .disabled(isSaveDisabled)
                }
            }
        }
    }
}
