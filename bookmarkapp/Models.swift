import Foundation
import SwiftData

@Model
final class Book {
    var id: UUID
    var title: String
    var author: String?
    var createdAt: Date
    var quotes: [Quote]

    init(id: UUID = UUID(), title: String, author: String? = nil, createdAt: Date = Date(), quotes: [Quote] = []) {
        self.id = id
        self.title = title
        self.author = author
        self.createdAt = createdAt
        self.quotes = quotes
    }
}

extension Book {
    /// The most recent date when this book or any of its quotes were updated.
    var lastUpdatedAt: Date {
        let latestQuoteDate = quotes.map(\.createdAt).max()
        return max(createdAt, latestQuoteDate ?? createdAt)
    }
    
    /// Convenience accessor for the number of quotes in this book.
    var quotesCount: Int {
        quotes.count
    }
}

@Model
final class Quote {
    var id: UUID
    var text: String
    var page: String?
    var note: String?
    var createdAt: Date
    var book: Book?

    init(id: UUID = UUID(), text: String, page: String? = nil, note: String? = nil, createdAt: Date = Date(), book: Book? = nil) {
        self.id = id
        self.text = text
        self.page = page
        self.note = note
        self.createdAt = createdAt
        self.book = book
    }
}


