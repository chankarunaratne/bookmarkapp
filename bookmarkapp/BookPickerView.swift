import SwiftUI
import SwiftData

struct BookPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]

    @State private var newTitle: String = ""
    @State private var newAuthor: String = ""
    var onPicked: (Book) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Existing") {
                    if books.isEmpty {
                        Text("No folders yet").foregroundStyle(.secondary)
                    } else {
                        ForEach(books) { book in
                            Button {
                                onPicked(book)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                    if let a = book.author, !a.isEmpty {
                                        Text(a).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                Section("Create New") {
                    TextField("Title", text: $newTitle)
                    TextField("Author (optional)", text: $newAuthor)
                    Button("Create Folder") {
                        guard !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        let book = Book(title: newTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                                        author: newAuthor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : newAuthor)
                        modelContext.insert(book)
                        onPicked(book)
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Choose Folder")
        }
    }
}


