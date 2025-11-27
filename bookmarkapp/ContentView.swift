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
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Spacer()
                                ProfileIconButton()
                            }
                            
                            HomeContentView(
                                books: books,
                                highlights: recentHighlights
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
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
                    // Match Figma "heading-container": Inter Regular 16, Text/Loud [900],
                    // with a slight inset from the left.
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(AppColor.textLoud)
                    .padding(.leading, 12)
                
                // Let the trailing card visually extend past the screen edge
                // while keeping the leading edge aligned with the section title.
                MyBooksCarouselView(books: books)
                    .padding(.trailing, -20)
            }
            
            // Recent highlights
            if !highlights.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent highlights")
                            // Match Figma "heading-container": Inter Regular 16, Text/Loud [900],
                            // with the same 12pt left inset as the "My books" header.
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundStyle(AppColor.textLoud)
                            .padding(.leading, 12)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Text("Sort")
                                    // Label/Small – Inter Medium 14
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundStyle(AppColor.textPrimary)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold, design: .default))
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                            .padding(.leading, 14)
                            .padding(.trailing, 8)
                            .padding(.vertical, 6)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white)
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(highlights, id: \.quote.id) { item in
                            RecentHighlightCardView(
                                bookTitle: item.book.title,
                                quoteText: item.quote.text,
                                createdAt: item.quote.createdAt
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
        }
    }
}

private struct HomeBookCardView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                BookThumbnailView(book: book)
                    .frame(height: 74)
                    .frame(maxWidth: .infinity)
                    .clipShape(
                        UnevenRoundedRectangle(
                            cornerRadii: RectangleCornerRadii(
                                topLeading: 24,
                                bottomLeading: 0,
                                bottomTrailing: 0,
                                topTrailing: 24
                            )
                        )
                    )
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
            .padding(.horizontal, 10)
            .padding(.top, 12)
            .padding(.bottom, 10)
        }
        .frame(width: 148, height: 138, alignment: .topLeading)
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
    let createdAt: Date
    
    /// Shared relative date formatter for the "Added X ago" timestamp.
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    private var addedTimestampText: String {
        let relative = Self.relativeFormatter.localizedString(for: createdAt, relativeTo: Date())
        return "Added \(relative)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(bookTitle)
                    .font(AppFont.quoteCardTitle)
                    .foregroundStyle(AppColor.textLoud)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer(minLength: 8)
                
                Text(addedTimestampText)
                    .font(AppFont.quoteCardTimestamp)
                    .foregroundStyle(AppColor.textSubdued)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Text(quoteText)
                .font(AppFont.quoteCardBody)
                .foregroundStyle(AppColor.textPrimary)
                .lineSpacing(10)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColor.cardBorderStrong, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                )
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

// MARK: - Profile icon button (home, top-right)

/// Circular profile icon used at the top-right of the home screen.
/// Matches the Figma ellipse with a single-letter monogram. The action
/// is intentionally empty for now and will later open the profile menu.
private struct ProfileIconButton: View {
    var body: some View {
        Button(action: {
            // Placeholder – will be wired to a profile / settings menu later.
        }) {
            ZStack {
                Circle()
                    .fill(AppGradient.profileIcon)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.9), lineWidth: 2)
                    )
                
                Text("C")
                    .font(AppFont.profileInitial)
                    .foregroundStyle(Color.white)
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Book.self, Quote.self], inMemory: true)
}
