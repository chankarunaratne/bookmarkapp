//
//  ContentView.swift
//  bookmarkapp
//
//  Created by Chandima Karunaratne on 9/11/2025.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct ContentView: View {
    var onSaveHighlight: (() -> Void)?
    var onTapMyLibrary: (() -> Void)?
    
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]
    
    /// Most recent quote per book, ordered by quote recency.
    private var recentHighlights: [(book: Book, quote: Quote)] {
        var seenBookIDs = Set<UUID>()
        var result: [(Book, Quote)] = []
        
        for quote in quotes {
            guard let book = quote.book else { continue }
            let bookID = book.id
            if seenBookIDs.contains(bookID) { continue }
            
            seenBookIDs.insert(bookID)
            result.append((book, quote))
            
            if result.count >= 5 { break }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            if books.isEmpty {
                emptyStateView
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header title
                        HStack {
                            Text("Home")
                                .font(AppFont.largeTitle)
                                .foregroundStyle(AppColor.textLoud)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(AppColor.glassIconForeground)
                                    .frame(width: 48, height: 48)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 8)
                        
                        // Content sections
                        HomeContentView(
                            books: books,
                            highlights: recentHighlights,
                            onSaveHighlight: onSaveHighlight,
                            onTapMyLibrary: onTapMyLibrary
                        )
                        .padding(.top, 40)
                    }
                    .padding(.bottom, 40)
                }
                .background(Color.white.ignoresSafeArea())
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Home")
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.textLoud)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.glassIconForeground)
                        .frame(width: 48, height: 48)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            
            VStack(spacing: 32) {
                Spacer()
                
                Image("no-books-image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 124)
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Save your first highlight")
                            .font(AppFont.emptyStateTitle)
                            .foregroundStyle(AppColor.textPrimary)
                        
                        Text("This is where your book highlights will live.\nScan a page to start remembering what you read.")
                            .font(AppFont.emptyStateBody)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    Button(action: { onSaveHighlight?() }) {
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

// MARK: - Home content (Recent books carousel + Recent highlights)

private struct HomeContentView: View {
    let books: [Book]
    let highlights: [(book: Book, quote: Quote)]
    var onSaveHighlight: (() -> Void)?
    var onTapMyLibrary: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Recent books section
            VStack(alignment: .leading, spacing: 16) {
                Button(action: { onTapMyLibrary?() }) {
                    HStack(spacing: 2) {
                        Text("My library")
                            .font(AppFont.homeSectionTitle)
                            .foregroundStyle(AppColor.textLoud)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColor.textLoud)
                    }
                    .padding(.leading, 32)
                }
                .buttonStyle(.plain)
                
                RecentBooksCarouselView(books: books)
            }
            
            // Recent highlights section
            if highlights.isEmpty {
                highlightsEmptyStateView
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent highlights")
                        .font(AppFont.homeSectionTitle)
                        .foregroundStyle(AppColor.textLoud)
                        .padding(.leading, 32)
                    
                    VStack(spacing: 20) {
                        ForEach(highlights, id: \.quote.id) { item in
                            RecentHighlightCardView(
                                book: item.book,
                                quoteText: item.quote.text,
                                createdAt: item.quote.createdAt
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private var highlightsEmptyStateView: some View {
        VStack(spacing: 32) {
            Image("open-book")
                .resizable()
                .scaledToFit()
                .frame(width: 142, height: 103)
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("No highlights yet")
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundStyle(AppColor.textMuted)
                    
                    Text("This is where your book highlights will live.\nScan a page to start remembering what\nyou read.")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Button(action: { onSaveHighlight?() }) {
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.background)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Recent Books Carousel

private struct RecentBooksCarouselView: View {
    let books: [Book]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(books) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        RecentBookCardView(book: book)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Recent Book Card (matches Figma 1.2 home design)

private struct RecentBookCardView: View {
    let book: Book
    
    private var initial: String {
        let trimmed = book.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "#" }
        return String(first).uppercased()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail area – gray background with book thumbnail centered
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
                .frame(height: 88)
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
                
                // Book icon with engraved initial (no gradient background)
                BookIconView(book: book)
                    .frame(width: 66, height: 92)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .offset(y: 18)
            }
            .frame(height: 88)
            .clipped()
            
            // Book details
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
        .frame(width: 148)
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

// MARK: - Book Icon View (just the book-thumbnail-icon + engraved letter, no gradient background)

private struct BookIconView: View {
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
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                case .failure:
                    monogramView
                case .empty:
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
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
            
            ZStack {
                Image("book-thumbnail-icon")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: bookWidth)
                
                Text(initial)
                    .font(AppFont.bookInitial)
                    .foregroundStyle(AppColor.bookThumbnailLetter)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

// MARK: - Recent Highlight Card (Figma design with book cover + quote)

private struct RecentHighlightCardView: View {
    let book: Book
    let quoteText: String
    let createdAt: Date
    
    /// Shared relative date formatter for the timestamp.
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    private var timestampText: String {
        Self.relativeFormatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: book title + timestamp
            HStack(alignment: .lastTextBaseline) {
                Text(book.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.textLoud)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer(minLength: 8)
                
                Text(timestampText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppColor.textSubdued)
                    .lineLimit(1)
            }
            
            // Body: book cover + quote text
            HStack(alignment: .center, spacing: 16) {
                // Book cover thumbnail (icon + engraved initial)
                BookIconView(book: book)
                    .frame(width: 72, height: 100)
                
                // Quote text
                Text("\u{201C}\(quoteText)\u{201D}")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundStyle(AppColor.textMuted)
                    .lineSpacing(6)
                    .lineLimit(4)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 1)
        )
        // View-only: no interaction on the card itself.
        .allowsHitTesting(false)
    }
}

/// Identifiable & Hashable wrapper so the OCR destination is only presented when
/// there is a concrete image, avoiding empty navigation state.
struct OCRImageItem: Identifiable, Hashable {
    let id = UUID()
    let image: UIImage

    static func == (lhs: OCRImageItem, rhs: OCRImageItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



#Preview {
    ContentView(onSaveHighlight: {}, onTapMyLibrary: {})
        .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}
