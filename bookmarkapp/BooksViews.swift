import SwiftUI
import SwiftData

struct MyBooksView: View {
    @State private var isPresentingNewBook: Bool = false
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    @State private var searchText: String = ""
    @State private var showBookToast: Bool = false
    @State private var bookWasAdded: Bool = false
    
    private var filtered: [Book] {
        guard !searchText.isEmpty else { return books }
        return books.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if books.isEmpty {
                    libraryEmptyStateView
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            LazyVGrid(columns: gridColumns, spacing: 14) {
                                ForEach(filtered) { book in
                                    NavigationLink(destination: BookDetailView(book: book)) {
                                        LibraryBookCardView(book: book)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        .padding(.bottom, 40)
                    }
                    .background(Color.white.ignoresSafeArea())
                }
            }
            .navigationTitle("My library")
            .toolbarTitleDisplayMode(.inlineLarge)
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
        .successToast(isPresented: $showBookToast, message: "Book created successfully")
        .sheet(isPresented: $isPresentingNewBook, onDismiss: {
            if bookWasAdded {
                bookWasAdded = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation {
                        showBookToast = true
                    }
                }
            }
        }) {
            AddBookView { _ in
                bookWasAdded = true
            }
        }
    }
    
    private var libraryEmptyStateView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                Spacer()
                
                Image("no-books-image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 124)
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Create your first book")
                            .font(AppFont.emptyStateTitle)
                            .foregroundStyle(AppColor.textPrimary)
                        
                        Text("This is where your books will live. Create a\nbook to save and group your highlights.")
                            .font(AppFont.emptyStateBody)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    Button(action: { isPresentingNewBook = true }) {
                        Text("Create a book")
                            .font(AppFont.buttonLabel)
                            .foregroundStyle(.white)
                            .frame(height: 36)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppColor.buttonDark)
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 36)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.background)
            )
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}



// MARK: - Library Book Card (matches Figma design for My Library grid)

/// Book card used on the My Library screen.
/// Top area: gray (#F3F5F7) with book cover centered, rounded top corners (24pt).
/// Bottom area: white with title + author, rounded bottom corners (24pt).
struct LibraryBookCardView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail area – gray background with book cover centered
            ZStack {
                // Gray background with rounded top corners
                UnevenRoundedRectangle(
                    cornerRadii: RectangleCornerRadii(
                        topLeading: 24,
                        bottomLeading: 0,
                        bottomTrailing: 0,
                        topTrailing: 24
                    )
                )
                .fill(Color(red: 0.953, green: 0.961, blue: 0.969)) // #F3F5F7
                .frame(height: 110)
                .overlay(
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 24,
                            bottomLeading: 0,
                            bottomTrailing: 0,
                            topTrailing: 24
                        )
                    )
                    .stroke(AppColor.cardBorder, lineWidth: 0.5)
                )
                
                // Book cover image or monogram icon
                LibraryBookIconView(book: book)
                    .frame(width: 72, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .offset(y: book.coverURL != nil ? 18 : 12)
            }
            .frame(height: 110)
            .clipped()
            
            // Book details area
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppColor.textLoud)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text((book.author?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { !$0.isEmpty ? $0 : nil } ?? "Unknown author")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppColor.textNormal)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 0.5)
        )
        .shadow(color: Color(red: 0.071, green: 0.216, blue: 0.412).opacity(0.08), radius: 1, x: 0, y: 1)
        .shadow(color: Color(red: 0.035, green: 0.098, blue: 0.282).opacity(0.13), radius: 0, x: 0, y: 0)
    }
}

// MARK: - Library Book Icon View (cover image or monogram for library cards)

/// Displays the book cover (from URL) or a monogram placeholder.
/// Sized for the library card (72×100).
private struct LibraryBookIconView: View {
    let book: Book
    
    private var initial: String {
        let trimmed = book.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "#" }
        return String(first).uppercased()
    }
    
    var body: some View {
        if let urlString = book.coverURL, let url = URL(string: urlString) {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    monogramView
                case .empty:
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppColor.background)
                        .overlay {
                            ProgressView()
                                .tint(AppColor.textSubdued)
                        }
                }
            }
        } else {
            monogramView
        }
    }
    
    private var monogramView: some View {
        GeometryReader { proxy in
            let bookWidth = proxy.size.width
            
            ZStack(alignment: .top) {
                Image(book.thumbnailAssetName)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: bookWidth)
                
                Text(initial)
                    .font(AppFont.bookInitial)
                    .foregroundStyle(BookCoverColor(rawColorString: book.coverColor).letterColor)
                    .padding(.top, bookWidth * 0.272)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

// MARK: - BooksListView (used by other parts of the app, e.g. BookPicker)

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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var quotePendingDeletion: Quote?
    @State private var isShowingDeleteConfirm: Bool = false
    @State private var isShowingDeleteBookConfirm: Bool = false
    @State private var showCamera: Bool = false
    @State private var ocrImageItem: OCRImageItem?
    @State private var showHighlightToast: Bool = false
    @State private var pendingHighlightToast: Bool = false
    @State private var pendingCameraRetake: Bool = false
    
    private var sortedQuotes: [Quote] {
        book.quotes.sorted { $0.createdAt > $1.createdAt }
    }
    
    private var bookDetailEmptyStateView: some View {
        VStack(spacing: 24) {
            Image("no-books-image")
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 124)
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("No highlights yet")
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundStyle(AppColor.textMuted)
                    
                    Text("Scan a page to save your first highlight.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Button(action: { showCamera = true }) {
                    Text("Save a highlight")
                        .font(AppFont.buttonLabel)
                        .foregroundStyle(.white)
                        .frame(height: 36)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(AppColor.buttonDark)
                                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 36)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.background)
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: – Book Header
                    BookDetailHeaderView(book: book)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    if sortedQuotes.isEmpty {
                        // MARK: – Empty State
                        bookDetailEmptyStateView
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 20)
                    } else {
                        // MARK: – Quotes List
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(sortedQuotes.enumerated()), id: \.element.id) { index, quote in
                                if index > 0 {
                                    Rectangle()
                                        .fill(AppColor.cardBorder)
                                        .frame(height: 1)
                                        .padding(.horizontal, 20)
                                }
                                
                                NavigationLink(destination: QuoteDetailView(quote: quote)) {
                                    QuoteRowView(quote: quote, onDelete: {
                                        quotePendingDeletion = quote
                                        isShowingDeleteConfirm = true
                                    })
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                                .padding(.top, index == 0 ? 24 : 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .frame(minHeight: sortedQuotes.isEmpty ? geometry.size.height : nil, alignment: .top)
                .padding(.bottom, sortedQuotes.isEmpty ? 0 : 40)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCamera = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        isShowingDeleteBookConfirm = true
                    } label: {
                        Label("Delete book", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
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
        .alert("Delete this book?", isPresented: $isShowingDeleteBookConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(book)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete the book and all of its highlights. This action cannot be undone.")
        }
        .successToast(isPresented: $showHighlightToast, message: "Highlight added successfully")
        .fullScreenCover(isPresented: $showCamera) {
            CustomCameraView { img in
                ocrImageItem = OCRImageItem(image: img)
            }
        }
        .fullScreenCover(item: $ocrImageItem, onDismiss: {
            if pendingCameraRetake {
                pendingCameraRetake = false
                showCamera = true
            }
            if pendingHighlightToast {
                pendingHighlightToast = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation {
                        showHighlightToast = true
                    }
                }
            }
        }) { item in
            NavigationStack {
                OCRReviewView(
                    image: item.image,
                    onRescan: {
                        pendingCameraRetake = true
                        ocrImageItem = nil
                    },
                    preselectedBook: book
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .highlightAdded)) { _ in
            pendingHighlightToast = true
        }
    }
}

// MARK: - Book Detail Header (cover + info)

/// Matches the Figma "header" frame: cover image left, book info right.
private struct BookDetailHeaderView: View {
    let book: Book
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Book cover
            BookDetailCoverView(book: book)
                .frame(width: 123, height: 172)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
            
            // Book info
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.system(size: 32, weight: .regular, design: .default))
                    .foregroundStyle(Color.black)
                    .lineLimit(3)
                    .padding(.top, 4)
                
                Text((book.author?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { !$0.isEmpty ? $0 : nil } ?? "Unknown author")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(AppColor.textNormal) // #666D80
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text(book.quotesCount == 0 ? "No highlights yet" : "\(book.quotesCount) highlight\(book.quotesCount == 1 ? "" : "s")")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(AppColor.textNormal)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppColor.background) // #F6F8FA
                )
            }
            
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Book Detail Cover View

/// Shows the book cover at the larger detail size, or falls back to a monogram.
private struct BookDetailCoverView: View {
    let book: Book
    
    private var initial: String {
        let trimmed = book.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "#" }
        return String(first).uppercased()
    }
    
    var body: some View {
        if let urlString = book.coverURL, let url = URL(string: urlString) {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    monogramView
                case .empty:
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColor.background)
                        .overlay {
                            ProgressView()
                                .tint(AppColor.textSubdued)
                        }
                }
            }
        } else {
            monogramView
        }
    }
    
    private var monogramView: some View {
        GeometryReader { proxy in
            let bookWidth = proxy.size.width
            
            ZStack(alignment: .top) {
                Image(book.thumbnailAssetName)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: bookWidth)
                
                Text(initial)
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .foregroundStyle(BookCoverColor(rawColorString: book.coverColor).letterColor)
                    .padding(.top, bookWidth * 0.272)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

// MARK: - Quote Row View

/// A single quote row matching the Figma design: timestamp + menu icon on top, quote body below.
private struct QuoteRowView: View {
    let quote: Quote
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Timestamp row
            HStack {
                Text(quote.createdAt.relativeDescription)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(AppColor.textSubdued) // #818898
                
                Spacer()
                
                Menu {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        UIPasteboard.general.string = quote.text
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            shareQuoteAsImage(quote: quote)
                        }
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColor.textSubdued)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            }
            
            // Quote body text
            Text(quote.text)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundStyle(AppColor.textMuted) // #36394A
                .lineSpacing(8) // ~32pt line height for 18pt text
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Quote Detail View

/// Full-screen quote view matching Figma "5.3 in-quote" design.
/// Shows the timestamp and full quote text with a native back button and ellipsis toolbar button.
struct QuoteDetailView: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingDeleteConfirm: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                // Timestamp
                Text(quote.createdAt.relativeDescription)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(AppColor.textSubdued) // #818898
                
                // Full quote text
                Text(quote.text)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(AppColor.textMuted) // #36394A
                    .lineSpacing(8) // ~32pt line height for 18pt text
                    .fixedSize(horizontal: false, vertical: true)

                if quote.page != nil || quote.note != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        if let page = quote.page, !page.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "book.pages")
                                    .font(.system(size: 14, weight: .regular))
                                Text("Page \(page)")
                                    .font(.system(size: 15, weight: .regular))
                            }
                            .foregroundStyle(AppColor.textSubdued)
                        }

                        if let note = quote.note, !note.isEmpty {
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 14, weight: .regular))
                                    .padding(.top, 2)
                                Text(note)
                                    .font(.system(size: 15, weight: .regular))
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .foregroundStyle(AppColor.textSubdued)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        UIPasteboard.general.string = quote.text
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            shareQuoteAsImage(quote: quote)
                        }
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        isShowingDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .alert("Delete this quote?", isPresented: $isShowingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(quote)
                isShowingDeleteConfirm = false
                DispatchQueue.main.async {
                    withAnimation {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete the quote permanently. This action cannot be undone.")
        }
    }
}

// MARK: - Quote Share Card View

/// Renders a shareable quote card matching the Figma design.
/// Used with ImageRenderer to produce a PNG image for the share sheet.
private struct QuoteShareCardView: View {
    let quoteText: String
    let bookTitle: String
    let authorName: String
    let coverImage: UIImage?
    let thumbnailAssetName: String
    let coverColor: BookCoverColor
    let bookInitial: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Group {
                        if let coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        } else {
                            ZStack(alignment: .top) {
                                Image(thumbnailAssetName)
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 50)
                                
                                Text(bookInitial)
                                    .font(.system(size: 16, weight: .regular, design: .serif))
                                    .foregroundStyle(coverColor.letterColor)
                                    .padding(.top, 50 * 0.272)
                            }
                            .frame(width: 50, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(bookTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColor.textMuted)
                            .tracking(-0.43)
                            .lineLimit(2)
                        
                        Text(authorName)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(AppColor.textNormal)
                            .lineLimit(2)
                    }
                    .padding(.top, 4)
                    
                    Spacer(minLength: 0)
                }
                
                Text("\u{201C}\(quoteText)\u{201D}")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(AppColor.textMuted)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text("@rememberlyapp")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppColor.textSubdued)
                .tracking(-0.16)
        }
        .padding(16)
        .frame(width: 322, alignment: .leading)
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(AppColor.cardBorderStrong, lineWidth: 1)
        )
        .shadow(color: Color(red: 0.035, green: 0.098, blue: 0.282).opacity(0.13), radius: 0, x: 0, y: 0)
        .shadow(color: Color(red: 0.071, green: 0.216, blue: 0.412).opacity(0.08), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Share Quote as Image

@MainActor
private func shareQuoteAsImage(quote: Quote) {
    let book = quote.book
    let bookTitle = book?.title ?? "Untitled"
    let authorName = (book?.author?.trimmingCharacters(in: .whitespacesAndNewlines))
        .flatMap { !$0.isEmpty ? $0 : nil } ?? "Unknown author"
    
    var coverImage: UIImage? = nil
    if let urlString = book?.coverURL {
        coverImage = ImageCache.shared.getImage(for: urlString)
    }
    
    let coverColor = BookCoverColor(rawColorString: book?.coverColor ?? "blue")
    let trimmedTitle = (book?.title ?? "#").trimmingCharacters(in: .whitespacesAndNewlines)
    let bookInitial = trimmedTitle.isEmpty ? "#" : String(trimmedTitle.prefix(1)).uppercased()
    
    let cardView = QuoteShareCardView(
        quoteText: quote.text,
        bookTitle: bookTitle,
        authorName: authorName,
        coverImage: coverImage,
        thumbnailAssetName: book?.thumbnailAssetName ?? "book-thumbnail-icon-blue",
        coverColor: coverColor,
        bookInitial: bookInitial
    )
    
    let renderer = ImageRenderer(content: cardView)
    renderer.scale = UIScreen.main.scale
    
    guard let image = renderer.uiImage else { return }
    
    let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
    
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootVC = windowScene.windows.first?.rootViewController else { return }
    
    var topVC = rootVC
    while let presented = topVC.presentedViewController {
        topVC = presented
    }
    
    activityVC.popoverPresentationController?.sourceView = topVC.view
    activityVC.popoverPresentationController?.sourceRect = CGRect(
        x: topVC.view.bounds.midX,
        y: topVC.view.bounds.midY,
        width: 0,
        height: 0
    )
    activityVC.popoverPresentationController?.permittedArrowDirections = []
    
    topVC.present(activityVC, animated: true)
}

// MARK: - Date Extension for Relative Descriptions

private extension Date {
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
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
        // Use a small palette of gradients and select one based on the book title
        // so that different books get different (but stable) backgrounds.
        let palettes: [ThumbnailPalette] = [
            ThumbnailPalette(background: AppGradient.bookThumbnailPink),
            ThumbnailPalette(background: AppGradient.bookThumbnailGold),
            ThumbnailPalette(background: AppGradient.bookThumbnailPink)
        ]
        
        // Ensure the "Random book" example uses the gold gradient so it is
        // clearly visible in the app for design review.
        let normalizedTitle = book.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedTitle.caseInsensitiveCompare("Random book") == .orderedSame {
            return ThumbnailPalette(background: AppGradient.bookThumbnailGold)
        }
        
        let idx = abs(normalizedTitle.hashValue) % palettes.count
        return palettes[idx]
    }
    
    var body: some View {
        if let urlString = book.coverURL, let url = URL(string: urlString) {
            // Remote cover from Open Library
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    monogramView
                case .empty:
                    Rectangle()
                        .fill(AppColor.background)
                        .overlay {
                            ProgressView()
                                .tint(AppColor.textSubdued)
                        }
                }
            }
        } else {
            monogramView
        }
    }
    
    private var monogramView: some View {
        Rectangle()
            .fill(palette.background)
            .overlay {
                GeometryReader { proxy in
                    // Small top inset so the colored background is visible above the book,
                    // matching the Figma spec (≈16pt on a 74pt-tall background).
                    let topPadding: CGFloat = proxy.size.height * 0.08
                    let bookWidth: CGFloat = min(67, proxy.size.width * 0.75) // keep around 67pt, maintain aspect ratio
                    let letterOffset: CGFloat = bookWidth * 0.272
                    // Shift the entire book/letter stack downward so that the lower
                    // portion of the book is clipped by the bottom edge of the thumbnail,
                    // creating the effect of the book emerging from behind the white section.
                    let contentOffsetY: CGFloat = proxy.size.height * 0.18
                    
                    ZStack(alignment: .top) {
                        // Book illustration, anchored to the top with a small inset so the
                        // background color is visible above it. The view itself clips the
                        // bottom of the book so only the upper portion is shown.
                        Image(book.thumbnailAssetName)
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
                            .foregroundStyle(BookCoverColor(rawColorString: book.coverColor).letterColor)
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
