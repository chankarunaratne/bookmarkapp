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
    // Home data
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
            
            // Limit to a reasonable number for the home screen.
            if result.count >= 5 { break }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    if books.isEmpty {
                        // Fallback to the original home layout when there are no books yet,
                        // so the onboarding / empty state behaviour remains unchanged.
                        header
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                        
                        BooksListView(showsSearchField: false, showsSectionHeader: false)
                            .padding(.horizontal, 20)
                    } else {
                        HomeContentView(
                            books: books,
                            highlights: recentHighlights
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(AppColor.background.ignoresSafeArea())
        }
    }
    
    private var header: some View {
        VStack(spacing: 16) {
            Text("Booklights")
                .font(AppFont.screenTitle)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Rectangle()
                .fill(AppColor.cardBorder)
                .frame(height: 1)
        }
    }
}

// MARK: - Home content (My books carousel + Recent highlights)

private struct HomeContentView: View {
    let books: [Book]
    let highlights: [(book: Book, quote: Quote)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // My books
            VStack(alignment: .leading, spacing: 12) {
                Text("My books")
                    .font(AppFont.sectionTitle)
                    .foregroundStyle(AppColor.textSecondary)
                
                MyBooksCarouselView(books: books)
            }
            
            // Recent highlights
            if !highlights.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent highlights")
                        .font(AppFont.sectionTitle)
                        .foregroundStyle(AppColor.textSecondary)
                    
                    VStack(spacing: 12) {
                        ForEach(highlights, id: \.quote.id) { item in
                            RecentHighlightCardView(
                                bookTitle: item.book.title,
                                quoteText: item.quote.text
                            )
                        }
                    }
                }
            }
        }
    }
}

private struct MyBooksCarouselView: View {
    let books: [Book]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(books) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        HomeBookCardView(book: book)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
            // Let the trailing card sit flush with the screen edge while
            // the leading card aligns with the section text.
            .padding(.trailing, 20)
        }
    }
}

private struct HomeBookCardView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                BookThumbnailView(book: book)
                    .frame(maxWidth: .infinity, minHeight: 74, maxHeight: 74)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
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
                        .padding(.trailing, 6)
                        .padding(.top, 6)
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
        .padding(10)
        .frame(width: 124, height: 130, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColor.cardBorder, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                )
        )
        .clipped()
    }
}

private struct RecentHighlightCardView: View {
    let bookTitle: String
    let quoteText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image("card-book-icon")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 16, height: 24)
                
                Text(bookTitle)
                    .font(AppFont.sectionTitle)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Text(quoteText)
                .font(AppFont.quoteBody)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppColor.cardBorder, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
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
    ContentView()
        .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}
