import SwiftUI
import SwiftData

// MARK: - Select Book Screen

struct BookPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]

    @State private var searchQuery: String = ""
    @State private var isShowingAddBook: Bool = false

    var onPicked: (Book) -> Void

    private var filteredBooks: [Book] {
        if searchQuery.isEmpty { return books }
        return books.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BookSearchField(text: $searchQuery)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if books.isEmpty {
                    Spacer()
                    Text("No books yet. Add a new book to get started")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                } else if filteredBooks.isEmpty {
                    Spacer()
                    Text("No books matching \"\(searchQuery)\"")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(filteredBooks) { book in
                                SelectBookRow(book: book) {
                                    onPicked(book)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color.white)
            .navigationTitle("Select book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddBook = true
                    } label: {
                        Text("Add new")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppColor.glassIconForeground)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddBook) {
                AddBookView { book in
                    isShowingAddBook = false
                    onPicked(book)
                }
            }
        }
    }
}

// MARK: - Select Book Row

private struct SelectBookRow: View {
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
        Button(action: onSelect) {
            HStack(spacing: 16) {
                BookThumbnailView(book: book)
                    .frame(width: 40, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(book.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }
                .padding(.top, 4)

                Spacer(minLength: 8)

                Image(systemName: "plus.circle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(AppColor.cardBorderStrong)
                    .frame(width: 32, height: 32)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add quote to \(book.title)")
    }
}

// MARK: - Book Search Field

private struct BookSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundStyle(Color(.placeholderText))

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Search")
                        .font(.system(size: 17))
                        .foregroundStyle(Color(.placeholderText))
                }
                TextField("", text: $text)
                    .font(.system(size: 17))
                    .foregroundStyle(AppColor.textPrimary)
            }

            if text.isEmpty {
                Image(systemName: "mic.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(Color(.placeholderText))
            } else {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(Color(.placeholderText))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            Capsule()
                .fill(Color(.tertiarySystemFill))
        )
    }
}

// MARK: - Add Book Screen (Search / Add Manually tabs)

struct AddBookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var searchService = OpenLibraryService()

    @State private var selectedTab: Int = 0
    @State private var manualTitle: String = ""
    @State private var manualAuthor: String = ""
    @State private var selectedColorIndex: Int = 0

    var onBookAdded: (Book) -> Void

    private var isSaveDisabled: Bool {
        if selectedTab == 0 { return true }   // Search tab uses row taps, not the save button
        return manualTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var titleInitial: String {
        let trimmed = manualTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "" }
        return String(first).uppercased()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Search").tag(0)
                    Text("Add manually").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if selectedTab == 0 {
                    searchTabContent
                } else {
                    addManuallyTabContent
                }
            }
            .background(Color.white)
            .navigationTitle("Add book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppColor.glassIconForeground)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedTab == 1 {
                        Button {
                            createManualBook()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.blue)
                        }
                        .disabled(isSaveDisabled)
                    }
                }
            }
        }
    }

    // MARK: - Search Tab

    private var searchTabContent: some View {
        VStack(spacing: 0) {
            // Search field
            AddBookTextField(
                label: "Title",
                placeholder: "Search by book title or author",
                text: $searchService.searchText
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Results / States
            if searchService.searchText.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                // Initial state – show banner
                ScrollView {
                    SearchBannerView()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
            } else if searchService.isSearching {
                Spacer()
                ProgressView()
                    .tint(AppColor.textSecondary)
                Spacer()
            } else if searchService.results.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(AppColor.textSubdued)
                    Text("No results found")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColor.textPrimary)
                    Text("Try a different search or add your book manually")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(searchService.results) { result in
                            SearchResultRow(result: result) {
                                createBookFromSearch(result)
                            }

                            // Divider between rows (except after last)
                            if result.id != searchService.results.last?.id {
                                Divider()
                                    .padding(.leading, 76)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Add Manually Tab

    private var addManuallyTabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                bookPreviewView

                VStack(alignment: .leading, spacing: 16) {
                    AddBookTextField(
                        label: "Title",
                        placeholder: "Enter book title",
                        text: $manualTitle
                    )

                    AddBookTextField(
                        label: "Author",
                        placeholder: "Enter author name",
                        text: $manualAuthor,
                        autocapitalization: .words
                    )

                    coverColorPicker
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
    }

    private var bookPreviewView: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColor.background)
                .frame(height: 155)
                .overlay {
                    ZStack(alignment: .bottom) {
                        ZStack(alignment: .top) {
                            Image("book-thumbnail-icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 114)

                            if !titleInitial.isEmpty {
                                Text(titleInitial)
                                    .font(.system(size: 44, weight: .regular, design: .serif))
                                    .foregroundStyle(AppColor.bookThumbnailLetter)
                                    .padding(.top, 31)
                            }
                        }
                        // Push the book down so it overflows the container and gets clipped
                        // by the rounded preview, instead of leaving empty space at the bottom.
                        .padding(.bottom, -34)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            Button { } label: {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(Color(white: 0.8))
                    )
            }
            .buttonStyle(.plain)
            .padding(6)
        }
    }

    private var coverColorPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cover color")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, 8)

            HStack(spacing: 11) {
                CoverColorCircle(color: CoverColor.blue, isSelected: selectedColorIndex == 0)
                CoverColorCircle(color: CoverColor.peach, isSelected: selectedColorIndex == 1)
                CoverColorCircle(color: CoverColor.gold, isSelected: selectedColorIndex == 2)
                CoverColorCircle(color: CoverColor.lavender, isSelected: selectedColorIndex == 3)
                CoverColorCircle(color: CoverColor.sage, isSelected: selectedColorIndex == 4)
            }
            .padding(.leading, 8)
        }
    }

    // MARK: - Book Creation

    private func createManualBook() {
        let trimmedTitle = manualTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        let trimmedAuthor = manualAuthor.trimmingCharacters(in: .whitespacesAndNewlines)

        let book = Book(
            title: trimmedTitle,
            author: trimmedAuthor.isEmpty ? nil : trimmedAuthor
        )
        modelContext.insert(book)
        onBookAdded(book)
        dismiss()
    }

    private func createBookFromSearch(_ result: OpenLibrarySearchResult) {
        let book = Book(
            title: result.title,
            author: result.author,
            coverURL: result.coverURL?.absoluteString
        )
        modelContext.insert(book)
        onBookAdded(book)
        dismiss()
    }
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    let result: OpenLibrarySearchResult
    var onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Cover thumbnail
                if let coverURL = result.coverURL {
                    CachedAsyncImage(url: coverURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        case .failure:
                            coverPlaceholder
                        case .empty:
                            ProgressView()
                                .frame(width: 44, height: 64)
                        }
                    }
                } else {
                    coverPlaceholder
                }

                // Title + Author
                VStack(alignment: .leading, spacing: 3) {
                    Text(result.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if let author = result.author {
                        Text(author)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "plus.circle")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(AppColor.cardBorderStrong)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add \(result.title)")
    }

    private var coverPlaceholder: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(AppColor.background)
            .frame(width: 44, height: 64)
            .overlay {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(AppColor.textSubdued)
            }
    }
}

// MARK: - Custom Text Field

private struct AddBookTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, 8)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(AppColor.textSubdued)
                }
                TextField("", text: $text)
                    .foregroundStyle(AppColor.textPrimary)
                    .textInputAutocapitalization(autocapitalization)
            }
            .font(.system(size: 17, weight: .regular))
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.cardBorder)
            )
        }
    }
}

// MARK: - Cover Colors

private enum CoverColor {
    static let blue = Color(red: 0.25, green: 0.56, blue: 0.97)
    static let peach = Color(red: 0.91, green: 0.55, blue: 0.50)
    static let gold = Color(red: 0.92, green: 0.80, blue: 0.42)
    static let lavender = Color(red: 0.70, green: 0.65, blue: 0.88)
    static let sage = Color(red: 0.72, green: 0.82, blue: 0.55)
}

private struct CoverColorCircle: View {
    let color: Color
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
        }
        .frame(width: isSelected ? 58 : 48, height: isSelected ? 58 : 48)
        .overlay {
            if isSelected {
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 2)
                    .padding(3)
            }
        }
    }
}

// MARK: - Search Banner

private struct SearchBannerView: View {
    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Image("book-search-banner")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 102)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .offset(y: 12)
            }
            .frame(width: 110, height: 102)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text("Search to auto-fill book details")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)

                Text("Get the real cover, title, and author automatically")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 102)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AppColor.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 1)
        )
    }
}
