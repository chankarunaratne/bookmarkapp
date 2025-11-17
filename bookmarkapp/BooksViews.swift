import SwiftUI
import SwiftData

struct MyBooksView: View {
    @State private var isPresentingNewBook: Bool = false
    
    var body: some View {
        NavigationStack {
            BooksListView()
                .padding(.horizontal)
                .navigationTitle("My Books")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresentingNewBook = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add new book")
                    }
                }
        }
        .sheet(isPresented: $isPresentingNewBook) {
            NavigationStack {
                NewBookView()
            }
        }
    }
}

struct BooksListView: View {
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    @State private var searchText: String = ""
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private var filtered: [Book] {
        guard !searchText.isEmpty else { return books }
        return books.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !books.isEmpty {
                TextField("Search books", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text("MY BOOKS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
                Text("\(filtered.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            
            if books.isEmpty {
                Text("No books yet. Use Save flow to create one.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            } else {
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(filtered) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookTileView(book: book)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct BookDetailView: View {
    @Bindable var book: Book
    @State private var query: String = ""
    
    private var filteredQuotes: [Quote] {
        guard !query.isEmpty else { return book.quotes.sorted { $0.createdAt > $1.createdAt } }
        return book.quotes.filter {
            $0.text.localizedCaseInsensitiveContains(query)
            || ($0.note ?? "").localizedCaseInsensitiveContains(query)
        }
        .sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        List {
            ForEach(filteredQuotes) { quote in
                VStack(alignment: .leading, spacing: 6) {
                    Text(quote.text)
                    if let note = quote.note, !note.isEmpty {
                        Text(note)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        if let page = quote.page, !page.isEmpty {
                            Text("p. \(page)")
                        }
                        Text(quote.createdAt, style: .date)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .searchable(text: $query)
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Shared book thumbnail used on the home grid and in the picker rows.
struct BookThumbnailView: View {
    let book: Book
    
    private var initial: String {
        let trimmed = book.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "#" }
        return String(first).uppercased()
    }
    
    private var accentColor: Color {
        let palette: [Color] = [
            Color(red: 0.96, green: 0.90, blue: 0.79),
            Color(red: 0.94, green: 0.83, blue: 0.83),
            Color(red: 0.84, green: 0.89, blue: 0.95),
            Color(red: 0.96, green: 0.86, blue: 0.93)
        ]
        let idx = abs(book.title.hashValue) % palette.count
        return palette[idx]
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(accentColor)
            .overlay(
                Text(initial)
                    .font(.system(size: 40, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.white.opacity(0.9))
            )
    }
}

struct BookTileView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                BookThumbnailView(book: book)
                    .frame(height: 110)
                
                if book.quotesCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "quote.opening")
                            .font(.caption2)
                        Text("\(book.quotesCount)")
                            .font(.caption2.weight(.semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThickMaterial)
                    .clipShape(Capsule())
                    .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                Text(book.lastUpdatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}
