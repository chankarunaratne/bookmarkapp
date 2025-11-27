import SwiftUI
import SwiftData

struct MyBooksView: View {
    @State private var isPresentingNewBook: Bool = false
    
    var body: some View {
        NavigationStack {
            BooksListView(showsActionsMenu: true)
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
    var showsActionsMenu: Bool = false
    var showsSearchField: Bool = true
    var showsSectionHeader: Bool = true
    
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
            if !books.isEmpty && showsSearchField {
                TextField("Search books", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
            }
            
            if showsSectionHeader {
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
            }
            
            if books.isEmpty {
                Text("No books yet. Use Save flow to create one.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            } else {
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    if showsActionsMenu {
                        ForEach(filtered) { book in
                            BookTileWithActions(book: book)
                        }
                    } else {
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
}

struct BookTileWithActions: View {
    let book: Book
    
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingActions: Bool = false
    @State private var isShowingRename: Bool = false
    @State private var isShowingDeleteConfirm: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(destination: BookDetailView(book: book)) {
                BookTileView(book: book)
            }
            .buttonStyle(.plain)
            
            Button {
                isShowingActions = true
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .padding(.trailing, 10)
                    .padding(.bottom, 8)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .confirmationDialog("Book actions", isPresented: $isShowingActions, titleVisibility: .visible) {
            Button("Rename") {
                isShowingRename = true
            }
            Button("Delete", role: .destructive) {
                isShowingDeleteConfirm = true
            }
        }
        .sheet(isPresented: $isShowingRename) {
            NavigationStack {
                RenameBookView(book: book)
            }
        }
        .alert("Delete this book?", isPresented: $isShowingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(book)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete the book and all of its quotes. This action cannot be undone.")
        }
    }
}

struct BookDetailView: View {
    @Bindable var book: Book
    @State private var query: String = ""
    @Environment(\.modelContext) private var modelContext
    @State private var quotePendingDeletion: Quote?
    @State private var isShowingDeleteConfirm: Bool = false
    
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
                VStack(alignment: .leading, spacing: 8) {
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
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Label("share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .allowsHitTesting(false)
                        
                        Button(role: .destructive) {
                            quotePendingDeletion = quote
                            isShowingDeleteConfirm = true
                        } label: {
                            Label("delete", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 6)
                }
                .padding(.vertical, 6)
            }
        }
        .searchable(text: $query)
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete this quote?", isPresented: $isShowingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let quote = quotePendingDeletion {
                    modelContext.delete(quote)
                    quotePendingDeletion = nil
                }
            }
            Button("Cancel", role: .cancel) {
                quotePendingDeletion = nil
            }
        } message: {
            Text("This will delete the quote permanently. This action cannot be undone.")
        }
    }
}

/// Shared book thumbnail used on the home grid and in the picker rows.
struct BookThumbnailView: View {
    let book: Book
    
    private struct ThumbnailPalette {
        let background: LinearGradient
    }
    
    private var initial: String {
        let trimmed = book.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "#" }
        return String(first).uppercased()
    }
    
    private var palette: ThumbnailPalette {
        let palettes: [ThumbnailPalette] = [
            ThumbnailPalette(
                background: AppGradient.bookThumbnailPink
            ),
            ThumbnailPalette(
                background: AppGradient.bookThumbnailPink
            ),
            ThumbnailPalette(
                background: AppGradient.bookThumbnailPink
            )
        ]
        let idx = abs(book.title.hashValue) % palettes.count
        return palettes[idx]
    }
    
    var body: some View {
        Rectangle()
            .fill(palette.background)
            .overlay {
                GeometryReader { proxy in
                    // Small top inset so the colored background is visible above the book,
                    // matching the Figma spec (≈16pt on a 74pt-tall background).
                    let topPadding: CGFloat = proxy.size.height * 0.08
                    let bookWidth: CGFloat = min(67, proxy.size.width * 0.75) // keep around 67pt, maintain aspect ratio
                    let letterOffset: CGFloat = 16 // distance from top of the book area (slightly higher for better visibility)
                    // Shift the entire book/letter stack downward so that the lower
                    // portion of the book is clipped by the bottom edge of the thumbnail,
                    // creating the effect of the book emerging from behind the white section.
                    let contentOffsetY: CGFloat = proxy.size.height * 0.18
                    
                    ZStack(alignment: .top) {
                        // Book illustration, anchored to the top with a small inset so the
                        // background color is visible above it. The view itself clips the
                        // bottom of the book so only the upper portion is shown.
                        Image("book-thumbnail-icon")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: bookWidth)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, topPadding)
                        
                        // First letter of the book title, centered horizontally and offset
                        // by ~20pt from the top of the book.
                        Text(initial)
                            .font(AppFont.bookInitial)
                            .foregroundStyle(AppColor.bookThumbnailLetter)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, topPadding + letterOffset)
                    }
                    .offset(y: contentOffsetY)
                    .clipped()
                }
            }
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
                    Text("\(book.quotesCount)")
                        .font(AppFont.quoteBadge)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(AppColor.quoteBadge)
                        )
                        .padding(.trailing, 10)
                        .padding(.top, 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(AppFont.bookTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text((book.author?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { !$0.isEmpty ? $0 : nil } ?? "Unknown author")
                    .font(AppFont.bookAuthor)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 190, maxHeight: 190, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                )
        )
    }
}

struct RenameBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var book: Book
    @State private var draftTitle: String
    
    init(book: Book) {
        self.book = book
        _draftTitle = State(initialValue: book.title)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Book title", text: $draftTitle)
                    .textInputAutocapitalization(.words)
            }
        }
        .navigationTitle("Rename Book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
                .disabled(draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private func save() {
        let trimmed = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        book.title = trimmed
        dismiss()
    }
}
